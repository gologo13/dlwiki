# DLWIKI(DownLoad WIKIpedia Keeping Topology)
============================================

Wikipedia の階層構造を保持しつつページをダウンロードするスクリプトです。トピックモデルの学習データ収集のために開発しました。

<pre>
出力例
.
└── 社会
    ├── 住民.html
    ├── 公人.html
    ├── 公共.html
    ├── 公民.html
    ├── 公益.html
    ├── 合意.html
    ├── 国士.html
    ├── 基準.html
    ├── 孤独.html
	...
</pre>

以下のURLの 100 のカテゴリをダウンロードの起点としています。

> [Wikipedia:カテゴリ - Wikipedia](http://ja.wikipedia.org/wiki/Wikipedia:%E3%82%AB%E3%83%86%E3%82%B4%E3%83%AA)

## INSTALLATION

<pre>
    $ cpanm Web::Scraper LWP::UserAgent GetOpt::Long File::Spec
</pre>

## USAGE

<pre>
    $ perl bin/dlwiki.pl
</pre>

### OPTIONS

<pre>
  -d, --depth LEVEL
      descend only level directories deep.
  -o, --out PATH
      specify a download directory.
  -p, --pages NUMBER
      specify a number of pages to download for each category.
  -s, --skip
      skip to download existing files for preventing overwriting.
  -h, --help
      show this message.
</pre>

## LICENSE

MIT License. Please see the LICENSE file for details.
