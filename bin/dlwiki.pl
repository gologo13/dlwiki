#!/usr/bin/perl
use strict;
use warnings;
use Web::Scraper;
use LWP::UserAgent;
use Getopt::Long;
use File::Spec;
use URI;
use Env qw/PWD/;
use encoding 'utf-8';

# command line options
my ($depth_limit, $out, $help, $num_pages, $skip);
GetOptions('depth=i' => \$depth_limit, 'out=s' => \$out,
           'pages=i' => \$num_pages, 'skip', => \$skip,
           'help' => \$help)
or die usage();
usage() if ($help);
$depth_limit = 0 if (!cmd_check($depth_limit, \"depth"));
$num_pages   = 0 if (!cmd_check($num_pages,   \"number of pages"));

my $ua = LWP::UserAgent->new();
my $wiki_scraper = scraper {
    process 'div#mw-subcategories a', 'subcats[]' => {
      href => '@href',
      title => 'TEXT'
    };
    process 'div#mw-pages a', 'pages[]' => {
      href => '@href',
      title => 'TEXT'
    };
};

my $BASE_URI = 'http://ja.wikipedia.org/wiki/Category:';
my @INITIAL_CATEOGRIES = get_initial_categories();

my $path = (defined($out)) ? File::Spec->rel2abs($out) : $PWD;
mkdir($path);
for my $i (0 .. $#INITIAL_CATEOGRIES) {
  my $cat = $INITIAL_CATEOGRIES[$i];
  my $uri = $BASE_URI.$cat;
  my $subpath = File::Spec->catfile($path, $cat);
  process_print(\"[$cat]", 0, $i, $#INITIAL_CATEOGRIES);
  rec_get(\$subpath, \URI->new($uri), 1, $depth_limit);
}

# find page links recursively
sub rec_get {
  my ($path, $uri, $cur_depth, $depth_limit) = @_;

  mkdir($$path);

  # exec scraping.
  my $ret = $wiki_scraper->scrape($$uri);

  # find subcategory links.
  if (defined($ret->{subcats})) {
    if ($depth_limit == 0 || $cur_depth < $depth_limit) {
      my @subcats = @{$ret->{subcats}};
      for my $i (0 .. $#subcats) {
        my $ref_elem = $subcats[$i];
        my ($href, $title) = values %{$ref_elem};
        my $new_path = File::Spec->catfile($$path, $title);
        process_print(\"[$title]", $cur_depth, $i, $#subcats);
        rec_get(\$new_path, \URI->new($href), $cur_depth+1, $depth_limit);
      }
    }
  }

  # download page links.
  if (defined($ret->{pages})) {
    my @pages = @{$ret->{pages}};
    for my $i (0 .. $#pages) {
      last if ($num_pages != 0 && $i+1 > $num_pages);
      my $ref_elem = $pages[$i];
      my ($href, $title) = values %{$ref_elem};
      process_print(\$title, $cur_depth, $i, $#pages);
      my $out = File::Spec->catfile($$path, "$title.html");
      next if (defined($skip) && -e $out);
      my $response = $ua->get($href);
      if ($response->is_success) {
        open(my $fh, ">", $out) or warn $!;
        print $fh $response->content;
        close($fh);
      } else {
        warn $response->status_line;
      }
    }
  }
}

# pretty print function
sub process_print {
  my ($title, $depth, $n, $total) = @_;
  printf("%s%0*d/%d: %s\n", "  " x $depth, length($total), $n+1, $total+1, $$title);
}

# check a command line argument
sub cmd_check {
  my ($arg, $msg) = @_;
  return undef if (!defined($arg));
  die "Invalid $$msg, must be greater than 0" if ($arg < 1);
  return 1; # $arg is a valid value.
}

# show usage
sub usage {
  print << "EOS";
Usage: $0 [-d LEVEL] [-o PATH] [-p NUM] [-s] [-h]
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
EOS
  exit(0);
}

# these categories come from this page.
# http://ja.wikipedia.org/wiki/Category:%E7%A4%BE%E4%BC%9A
sub get_initial_categories {
return qw/
社会
政治
経済
産業
交通
教育
歴史
福祉
医療
健康
環境
市民活動
平和
軍事
大学
芸術
文化
言語
宗教
娯楽
趣味
伝統芸能
文学
音楽
美術
映画
演劇
アニメ
漫画
イラストレーション
スポーツ
ゲーム
ギャンブル
身体装飾
食文化
建築
マスメディア
芸能
大陸
アジア
アフリカ
オセアニア
北アメリカ
南アメリカ
ヨーロッパ
日本
北海道
東北地方
関東地方
中部地方
近畿地方
中国地方
四国地方
九州地方
沖縄県
自然
宇宙
元素
気象
災害
海
生物
植物
動物
鉱物
学問
哲学
論理学
言語学
心理学
文学
宗教学
政治学
経営学
法学
経済学
社会学
教育学
数学
物理学
化学
生物学
人類学
地球科学
医学
薬学
歯学
農学
工学
技術
コンピュータ
コンピュータネットワーク
電子工学
バイオテクノロジー/;
}
