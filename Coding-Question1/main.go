package main
import (
	"fmt"
	"os"
	"strings"
)

func readWords(path string) (string, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		fmt.Printf("Error reading file %s: %v\n", path, err)
		return "", err
	}
	return string(data), nil
}

func getMostFrequentWord(data string) (int, string) {
	words := strings.Fields(data)

	// convert to lower case and put into map
	wordMap := make(map[string]int)
	largestWord := ""
	largestWordCount := 0
	for _, v := range(words) {
		lowerCaseWord := strings.ToLower(v)
		if count,ok := wordMap[lowerCaseWord]; ok {
			wordMap[lowerCaseWord] = count + 1
		} else {
			wordMap[lowerCaseWord] = 1
		}

		// check most frequent word
		if wordMap[lowerCaseWord] > largestWordCount {
			largestWord = lowerCaseWord
			largestWordCount = wordMap[lowerCaseWord]
		}
	}

	return largestWordCount, largestWord
}

func main() {
	data, err := readWords("words.txt")
	if err != nil {
		return
	}
	count, word := getMostFrequentWord(data)
	fmt.Printf("%v %v\n", count, word)

	return
}