# Cookiejar of Greed

## What is it?

Cookiejar of Greed is a practical cookiejar implementation for Ruby.  
It accepts and tolerates more HTTP cookies than the RFCs,
the goal is to solve real-world problems people are facing,
and maintains high compatibility with major browsers.

## Why another cookiejar?

To be exact, for me, I have an issue with the existing one.  
https://github.com/sparklemotion/http-cookie/issues/28  
Apart from what I directly encountered,
the code base seems unmaintained, hard to work with,
and plague with thread-safety issues.

IMO The existing one is beyond fixing, so I created another tiny one for myself,
implementing a subset of the former.

## Installation

~~~ruby
gem 'cookiejar_of_greed'
~~~

## Usage examples

#### Creating a cookiejar
~~~ruby
require 'cookiejar_of_greed'
cookie_jar = ::Greed::Cookie::Jar.new
~~~

#### Adding cookies to the jar
~~~ruby
# Whenever you receive a "set-cookie" header, just feed it to the jar
# everything else will be taken care of
cookie_jar.parse_set_cookie(
  'http://localhost/', # the document location that sent the header
  'cookiename=value; domain=localhost; max-age=3600' # the header
)
~~~

#### Persisting or serializing the content of the jar
~~~ruby
serializable_content = cookie_jar.dump
serialized_jar = ::YAML.dump(serializable_content)
# persist serialized_jar somewhere

# jar can be created with dumped states
rehydrated_jar = ::Greed::Cookie::Jar.new(serializable_content)
~~~

#### Retrieving cookies from the jar for a HTTP request
~~~ruby
cookie_header = cookie_jar.cookie_header_for('http://localhost/dashboard')
~~~

## Contributing

Even though I started the project for myself,
you can modify it to suit your use cases;
a pull request is always welcome and discussable.

## License

Cookiejar of Greed is released under the [BSD 3-Clause License](LICENSE.md). :tada: