Want to help out with KnightOS? Great! We'd be happy to have your help. There are
loads of things to work on. What are you interested in?

Assembly:       You could work directly on the kernel itself, or on the userspace.
C:              Most of the toolchain is written in C and more work is needed.
Python:         KDoc generates kernel documentation and could use your assistance.
HTML/CSS/JS:    knightos.org is always available for improvements.
LaTeX:          Want to help write the KnightOS manual?

If you can't write code, don't despair. Your help is valuable as well! You can
hang out with us online and offer your thoughts and feedback, and you can test the
system to make sure everything's in working order. You could also spread the good
word online and among your friends, getting more people excited about and involved
in KnightOS.

No matter what you're interested in, come join us on IRC - #knightos on
irc.freenode.net. We'll be hanging out to chat and direct new contributors and
excited users to the right place.

If you'd like to report bugs or contribute code to the kernel or userspace, the
rest of this document is for you.

# Reporting Bugs

Bugs may be reported on GitHub at the following addresses:

* Userspace: https://github.com/KnightOS/KnightOS/issues
* Kernel:    https://github.com/KnightOS/kernel/issues

Please try to find the right place to submit your issue. If in doubt, submit it to
the userspace repository. Please follow these guidelines when submitting bug
reports or feature requests:

- Use English to report bugs or request features
- Search existing issues to make sure we don't already know about it
- Please ensure your system and its kernel are up-to-date
- Provide clear instructions on how the error may be reproduced
- Mention what kind of calculator you are using (TI-83+, TI-84+ SE, etc)

# Submitting Code

When sending us code, be sure to follow the coding standards we have already set
in place. See the bottom of this document for examples. The procedure for offering
code is:

1. Create a fork on GitHub
2. Make your changes
3. Send us a pull request

Please hang out in the IRC channel so we can chat with you about your code.

# Code Style

KnightOS is built with many languages and each language has its own style. A short
example of each is shown here.

## z80 Assembly

    labelName:
        ld a, 10 + 0x13
        push af
        push bc
            add a, b
            jr c, labelName
        pop bc
        pop af
    .localLabel:
        dec a
        cp 10
        jr z, .localLabel
        ret

* Use 0xHEX, not $HEX or HEXh
* Use local labels where possible
* Instructions in lowercase
* camelCase for label names
* 4 spaces, not tabs
* Indent your code to reflect stack usage

## C

    char *returns_string(char *a, int b, struct some_struct c) {
    	b += 10;
    	int i;
    	for (i = 0; i < 10; i++) {
    		b += c.something;
    	}
        if (b > 40) {
            return a - b;
        }
    	return a + b;
    }

* Opening braces on the same line
* C99 is alright but we don't mind tradition
* Tabs instead of spaces
* `char * foobar` instead of `char* foobar`
* Single-line statments get braces anyway

## Python

    import foo
    import bar

    from baz import *

    def test(foo, bar):
        print("hello world")
        return foo + bar

* 4 spaces instead of tabs
* Group `import a`s seperate from `from a import b`s
* Pretty much standard Python

## CSS

    .foo-bar > a {
        color: red;
        background: transparent;
        border-radius: 5px;
    }

* 4 spaces instead of tabs
* Opening braces on the same line
* Use dashed-case for class names and IDs

# JavaScript

    var a = {
        foo: 'a',
        bar: 'b',
        baz: 100
    };

    function example(a, b, c) {
        if (typeof c === "undefined") {
            b = 10;
        }
        return a + b + c;
    }

* 4 spaces instead of tabs
* Opening brace on the same line
* Check for undefined with `typeof variable === "undefined"`

# Additional Guidelines

In the kernel, all registers that are not used for output must be kept intact.
Destroying shadow registers is acceptable but must be documented.

All public kernel functions must be documented. Do not use the ';;' syntax outside
of documentation.
