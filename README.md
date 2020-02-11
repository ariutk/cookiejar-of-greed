# Cookiejar of Greed

## What is it?

Cookiejar of Greed is a practical cookiejar implementation for Ruby.  
It accepts and tolerates more HTTP cookies than the RFCs,
the goal is to accomplish real-world tasks people are facing,
and highly compatible with major browsers.

## Why another cookiejar?

To be exact, for me, I have an issue with the existing one.  
https://github.com/sparklemotion/http-cookie/issues/28  
Apart from what I directly encountered,
the code base seems unmaintained, hard to work with,
and plague with thread-safety issues.

IMO The existing one is beyond fixing, so I created another tiny one for myself,
implementing a subset of the former.

## Contributing

Even though I started the project for myself,
you can modify it to suit your use cases;
a pull request is always welcome and discussable.

## License

Cookiejar of Greed is released under the [BSD 3-Clause License](LICENSE.md). :tada: