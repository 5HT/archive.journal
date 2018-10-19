# maxim.livejournal.com

These are sources of <a href="//maxim.livejournal.com">maxim.livejournal.com</a>,
personal work-life journal, that was recorded during 2009-2018 years by Maxim Sokhatsky.
This journal mainly covers three aspects of Maxim's being:
<a href="//longchenpa.guru">longchenpa.guru</a> (early years),
<a href="//synrc.space">synrc.space</a> (erlang years),
<a href="//groupoid.space">groupoid.space</a> (phd years).

## make word wrap and remove trailing spaces (MacOS)

```bash
 for i in *; do fold -s -w 80 $i > 1; mv 1 $i; done
 sed -i '' -E 's/[ '$'\t'']+$//' *
```

Maxim &copy; 2009—2018

