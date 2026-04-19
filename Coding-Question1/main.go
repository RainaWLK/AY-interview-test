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

// Filter symbols other than A-Z, a-z, 0-9
func cutSymbols(data string) string {
	result := []rune{}
	for _,v := range data {
		if (v >= 'A' && v <='Z') || (v >= 'a' && v <= 'z') || (v >= '0' && v <= '9') {
			result = append(result, v)
		}
	}
	return string(result)
}

func getMostFrequentWord(data string) (int, string) {
	words := strings.Fields(data)

	// convert to lower case and put into map
	wordMap := make(map[string]int)
	largestWord := ""
	largestWordCount := 0
	for _, v := range(words) {
		// get word in lower case
		lowerCaseWord := cutSymbols(strings.ToLower(v))

		// count the word
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

func mainFunction(source string) {
	data, err := readWords(source)
	if err != nil {
		return
	}
	count, word := getMostFrequentWord(data)
	if count == 0 {
		fmt.Println("Empty file.")
		return
	}
	fmt.Printf("%v %v\n", count, word)
	return
}

func main() {
	mainFunction("testcases/words.txt")

	// test cases
	// mainFunction("testcases/non-exists.txt")
	// mainFunction("testcases/empty.txt")
	// mainFunction("testcases/oldmacdonald.txt")

	return
}