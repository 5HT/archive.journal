# Namdak Tonpa Blog

These are sources of <a href="//tonpa.guru">tonpa.guru</a>,
personal work-life journal, that was recorded during 2009-2018 years by Maxim Sokhatsky.
This journal mainly covers three aspects of Maxim's being:
<a href="//longchenpa.guru">longchenpa.guru</a> (early years),
<a href="//n2o.im">n2o.im</a>&nbsp;(erlang years),
<a href="//groupoid.space">groupoid.space</a> (phd years).

## preprocess

Make word wrap and remove trailing spaces (MacOS).

```bash
$ for i in *; do fold -s -w 80 $i > 1; mv 1 $i; done
$ sed -i '' -E 's/[ '$'\t'']+$//' *
```

## read

As article names in cyrillic we need urlencode: https://gist.github.com/cdown/1163649

```bash
$ curl -vs https://raw.githubusercontent.com/`urlencode \
  "5HT/maxim.livejournal.com/master/articles/2012/2012-05-28 Erlang.txt"` 2>&1 | less
```

Maxim &copy; 2009—2019
