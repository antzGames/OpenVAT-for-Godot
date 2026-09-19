package main

import (
	"bufio"
	"os"
	"log"
	
	"compress/gzip"
	"io/ioutil"
)

func main() {
	if ( len(os.Args) < 2 ) {
		log.Print("No file provided")
		os.Exit(1)
	}

	source := os.Args[1]

	//case extention
	// html:
	// js:
	// else:
	// - comporess gzip
	compress(source)
}

func compress( source string ) {
	f, _ := os.Open("./" + source)

	reader := bufio.NewReader(f)
	content, _ := ioutil.ReadAll(reader)

	f.Close()

	dest := source + "_"

	f, _ = os.Create("./" + dest)

	w := gzip.NewWriter(f)
	w.Write(content)
	w.Close()
}
