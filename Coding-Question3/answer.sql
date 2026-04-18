select class from student_class where name = (
    select name from score order by score desc limit 1,1
);