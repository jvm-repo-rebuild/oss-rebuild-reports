#!/usr/bin/env bash

[ -d data ] || mkdir data
[ -f data/summary.md ] && rm -f data/summary.md
echo "npm https://www.npmjs.com/package/ JavaScript/TypeScript
pypi https://pypi.org/project/ Python
crates.io https://crates.io/crates/ Rust" | while read p url lang
do
  if [ ! -d data/$p ]
  then
    # extract data from oss-rebuild
    mkdir data/$p
    for l in a b c d e f g h i j k l m n o p q r s t u v x y z
    do
        oss-rebuild list $p $l | cut -d / -f 2- | sed -e 's_/_ _' -e 's_/_ _' > data/$p/$l.txt
    done
    oss-rebuild list $p @ | cut -d / -f 2- | sed -e 's_/_:_' -e 's_/_ _' -e 's_/_ _' -e 's_:_/_' > data/$p/@.txt
  fi

  du -sh data/$p
  releaseCount="$(cat data/$p/*.txt | wc -l | awk '{$1=$1};1')"
  packageCount="$(cat data/$p/*.txt | cut -d ' ' -f 1 | uniq | wc -l | awk '{$1=$1};1')"
  echo "releases: $releaseCount"
  echo "packages: $packageCount $url"
  cat data/$p/*.txt | cut -d ' ' -f 1 | uniq -c | awk '{$1=$1};1' > data/$p.txt

  echo "- $releaseCount :recycle: releases of $packageCount [$p packages]($p.md) ($lang)" >> data/summary.md

  echo "OSS Rebuild Results for $p
========

$releaseCount [:recycle: releases](https://github.com/jvm-repo-rebuild/reproducible-central/blob/master/doc/stabilize.md) of $packageCount [$p packages]($url..)

See [oss-rebuild usage](https://github.com/google/oss-rebuild#usage) for details on rebuilding or getting [rebuild attestation](https://github.com/google/oss-rebuild/blob/main/docs/builds/Rebuild@v0.1.md)

| package | releases | latest oss-rebuilt | latest |
| ------- | -------- | ------------------ | ------ |
$(while read n a
do
  echo "| [$a]($url$a) | $n :recycle: | $(grep -h "^$a " data/$p/*.txt | tail -1 | cut -d ' ' -f 2) | [![latest](https://img.shields.io/$p/v/$a)]($url$a) |"
done < data/$p.txt)" > $p.md
done

lead='^<!-- BEGIN GENERATED SUMMARY -->$'
tail='^<!-- END GENERATED SUMMARY -->$'
sed -e "/$lead/,/$tail/{ /$lead/{p; r data/summary.md
        }; /$tail/p; d }" README.md > README.new.md

[ -s README.new.md ] && rm README.md && mv README.new.md README.md