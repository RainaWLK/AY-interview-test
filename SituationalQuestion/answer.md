# Question1
從外往內看，因為是網頁，壓力的順序為 (假設在AWS)
```
frontend (or CDN) --> ALB --> backend service --> DB
```
1. frontend
    - 盡量採用前後端分離架構，並且確保cacheable
    - cacheable的網頁可以將CDN發揮到最大化
    - CDN可能要買更貴的方案

2. ALB
    - 大流量來之前先prewarming，或購買LCU Reservation

3. backend service
    - 程式是否已經善用cache
    - 程式是否有落實DB read/write分離
    - 有沒有一些DB operation是不需要立刻寫入的？可以decouple出去，丟到Queue再由另外的service去消化
    - 有無流量管制，排隊機制，避免同時間湧入過多導致DB, cache崩潰
    - 同上，搶購商品能否善用cache發號碼牌，再排隊結帳
    - 有無circuit breaker機制，寧願打掉一些連線，也不可讓DB崩潰
    - 主機scale out or scale up
    - 再確保DB不會崩潰的前提下做服務scale out

4. DB / cache
    - cache能否多台分流，如何設計
    - DB replications能否扛住大量的讀取流量，不夠的話是否要加replication
    - DB schema的設計會巨大影響到效能，是否已最佳化？
    - 當下有無OLAP的服務在運行給DB額外壓力，能否改期，或者做一台專屬的replication給OLAP使用

5. 分段測試
    - 每一段做壓力測試，針對壓力瓶頸做改善，比較有效率
    - 通常瓶頸都在自己寫的程式上


# Question2
先確認這台主機是"經常"timeout，還是"一直"都timeout
假設這台主機在ALB底下

### DB問題
1. 先檢查DB dashboard，確認DB, redis是正常的。有無踩到max connection，有的話就很可能是某個服務連不上的原因
    - 進DB看processlist (假設MySQL)，看是誰在灌DB，找出異常的連線原因，並將源頭關掉
    - 如果是新服務越來越多導致max connection不夠，則先放大max connection，再來討論要如何解決，是否要拆DB

### 服務或主機問題
1. 看ALB target group status，如果有unhealthy，代表主機/服務本身有問題，直接去主機內部檢查
2. 如果ALB target group status顯示healthy，代表health check有失真，查修完畢之後需要再回頭來檢視health check的問題。這種狀況通常不是主機壞掉，是服務自己出狀況
3. 看service log，如果有異狀，就能立即針對異狀做處理
4. 承step 1，有可能根本連不到主機，主機本身就掛了。先觀察主機的metrics有無異狀，然後主機掛掉只能stop / start，然後進去主機內部找syslog，看有沒有找出端倪  
如果是OOM當機的話可能可以找到oom killer的log，而如果是AWS hardware failure，有可能查不到任何異狀，只能請AWS support去機房查原因
5. 確認正常的主機上的服務版本，跟異常的是否一致

### 網路，AZ，機房問題
1. 有可能異常的主機位置，跟正常的不同。是那個區域的網路異常？如果懷疑是這樣，也許先撤掉這個區域，以免影響用戶體驗
2. 是否有人動過infra設定，這台主機的防火牆設定錯誤


# Question3
> 無法使用SSH key登入，代表sshd可能已經掛掉。AWS提供的各種login方式如果是基於ssh，也就無法運作
> 基於ssm agent的，或者serial console可能有機會，但我從未在sshd掛掉的時候成功用這些方式進去過

### 如果該服務可以scale out
首先確認一下這個服務能不能開兩組以上，如果可以，就比照一般的VM upgrade流程，先開出另一台主機的另一個服務，確認都上線正常，則將有問題的主機移出ALB target group  
然後重開機  
重開機讓sshd重新起來之後就可以連進去看原因，是oom還是別的原因壞掉

### DB replica
DB replica 1發生故障，如果要先將replica 1流量合併回master，做read/write合併之前必須先確認被接上流量的主機能否承受  
不能的話，先做好另一台replica 2，再將replica 1的流量導到replica 2，避免master崩潰

### DB master
傳統master-slave架構的RDBMS，master發生故障，必須先確保沒有寫入動作，可能要停機，才能將replica promote起來成為新的master，舊的master下下去查修
(新的cluster架構據說不用?)

### 如果該服務只能單點運作
如果這個服務必須是單點運作，就比較麻煩。必須看這台停機的影響有多大，挑個影響最小的時間去處理  
因為放著不管，可能當天或隔天就整個壞光導致更大損失

## 事後檢討
這題最重要的是，為什麼會發生sshd掛掉，是否因為OOM發生而將sshd kill掉?
為什麼會發生OOM？是否某個應用程式bug，或者某個操作吃掉大量RAM  
必須將主機上跑過的應用程式都查過一遍，找出哪個在吃RAM，否則還會再發生這類事故


# Question4
以EF(fluent bit)K為例
```
VM log --> fluent bit --> Elasticsearch -->　Kibana
```

### 程式端
需要訂出合適的log format，最重要的是必須帶時間，否則讓fluent bit用讀取時間去補上，會嚴重失真
> container環境或者輸出到syslog是會補上時間，但也是有失真，會影響後續debug

log直接輸出到stdout，由執行環境 (containerd or systemd)來定義輸出到哪個檔案，以及log rotate  
可以讓程式簡單一點

### fluent bit
output指向ES
- 如果服務是container based: input指向container log
- 如果服務是VM systemd: input指向daemon自己的log，或者如果它是輸出到syslog
- filter, parser按照log format，以及要輸出到ES的format，設定好

每台主機一個fluent bit，處理整台主機所有服務的log  
如果是k8s，則可以是daemon set，將VM的log folder掛載進去處理

> 將log成功導到既有的Elasticsearch系統後，就可以用既有的方式將log顯示在Kibana上




