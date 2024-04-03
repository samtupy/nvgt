# datastreams
Streams, also known as datastreams, are one of the primary ways of moving around and manipulating data in nvgt. With their convenient function calls, low memory footprint when dealing with large datasets and with their ability to connect to one another to create a chain of mutations on any data, datastreams are probably the most convenient method for data manipulation in NVGT that exist.

A datastream could be a file on disk, a file downloading from/uploading to the internet, a simple incapsolated string, or some sort of a manipulator such as an encoder, decryptor or compression stream.

Datastreams can roughly be split into 3 categories, or if you want to be really specific 2.5.
* sources: These streams are things like file objects, internet downloads, or really anything that either inputs new data into the application or outputs data from it. Thus, they can read, write or both depending on the properties of the stream.
* readers: These streams only support read/input operations, an example may be a decoder. Usually these attach to another stream, read data from the connected stream, and mutate that data as the stream is read from.
* writers: The polar opposite of readers, these streams usually connect to another stream E. a file object opened in writing mode where data gets mutated (usually encoded) before being written to the connected stream.

Ocasionally, you may see a reader referred to as a decoder, and a writer referred to as an encoder.

Particularly when considering reader and writer streams that manipulate data, you can typically chain any number of streams of the same type together to cause a sequence of data mutations to be performed in one function call. For example you could connect an inflating_reader to a hex_decoder that is in turn connected to a file object in read mode. From that point, calling any of the read functions associated with the inflating stream would automatically first read from the file, hex decode it, and decompress/inflate it as needed. Inversely, you could connect a deflating_writer to a hex encoder which is connected to a file object in write mode, causing any data written to the inflating stream to be compressed, hex encoded, and finally written to the file.

There are a few readers and writers that, instead of manipulating data in any way as they pass through, give you details about that data. You can ssee counting_reader and counting_writer as examples of this, these streams count the number of lines and characters that are read or written through them.

Lets put this together with a little demonstration. Say you have a compressed and hex encoded file with many lines in it, and you'd like to read the file while determining the line count as the file is read. You could execute the following, for example:
```
counting_reader f(inflating_reader(hex_decoder(file("test.txt", "rb"))));
string result;
while(f.good()) {
	result += f.read(100);
	alert("test", "currently on line " + f.lines + " on character position " + f.pos);
}
f.close();
alert("test", "The file contains a total of " + f.lines + " and after decoding, contains the following text: \n" + result);
```

More datastreams could be added to the engine at any time.

Note that most datastreams do not support seeking as this would result in needing to store more data in memory than we are comfortable with just as a start, however file objects and raw datastreams that read from a string do support seeking, E source streams. Other than these stream types, you should assume that seek operations will not work unless noted otherwise for each type of stream.

The available datastreams are listed below in this subsection of the documentation.
