# mdtohtml

This is a simple console application for processing markdown files to HTML.

In fact it is just a small wrapper around [fpc-markdown](https://github.com/mriscoc/fpc-markdown).
I wrote and tested it specifically under Amiga OS but it should run fine on every platform
supported by Free Pascal.


## Requirements

To compile `mdtohtml` you will need a descent version of Free Pascal and the
[fpc-markdown](https://github.com/mriscoc/fpc-markdown) units. The application should compile on
every platform which is supported by Free Pascal. I tested `mdtohtml` with Free Pascal 3.2.2 on Amiga OS 3.2.3.
The compiled binary should not have any specific dependencies.


## Usage

`mdtohtml` is invoked via Cli / Shell and supports the following options:

```shell
mdtohtml [-h|--help] -f|--file <input file> [-o|--outfile <output file>] [-m|--mode <markdown mode>] [-e|--encoding <character encoding>] [-t|--template <template file>]
```

Available options

- `-h|--help`: Displays a usage hint and exits. Other options are ignored.
- `-f|--file <input file>`: Name of the input file. Required.
- `-o|--outfile <output file>`: Name of the output file. If not specified, output will be written to standard output.
- `-m|--mode <markdown mode>`: Supported modes: DaringFileball, TxtMark, CommonMark.
See [fpc-markdown](https://github.com/mriscoc/fpc-markdown) for details.
- `-e|--encoding <encoding>`: This option does not change the way the input is processed! Character encoding of the
written file will always be the same as of the input file. The encoding value is written to the generated HTML as a meta
tag and should match your input file. Defaults to [Amiga-1251](https://www.iana.org/assignments/charset-reg/Amiga-1251).
- `-t|--template <template file>`: If no template file is provided, output will be encapsulated in a bare minimum HTML
frame. You can (and probably should) use a custom template to refine output. See provided demo template for supported
placeholders.

