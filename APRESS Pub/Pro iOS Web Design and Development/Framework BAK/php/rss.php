
<?php
   
   
   
   // define the namespaces that we are interested in
$ns = array
(
        "content" => "http://purl.org/rss/1.0/modules/content/",
        "wfw" => "http://wellformedweb.org/CommentAPI/",
        "dc" => "http://purl.org/dc/elements/1.1/"
);
// obtain the articles in the feeds, and construct an array of articles

$articles = array();

// step 1: get the feed
$blog_url = "HTTP://YOURSITE.COM/FEED.XML";

$rawFeed = file_get_contents($blog_url);
$xml = new SimpleXmlElement($rawFeed);

// step 2: extract the channel metadata

$channel = array();
$channel["title"]       = $xml->channel->title;
$channel["link"]        = $xml->channel->link;
$channel["description"] = $xml->channel->description;
$channel["pubDate"]     = $xml->pubDate;
$channel["timestamp"]   = strtotime($xml->pubDate);
$channel["generator"]   = $xml->generator;
$channel["language"]    = $xml->language;

// step 3: extract the articles

foreach ($xml->channel->item as $item)
{
        $article = array();
        $article["channel"] = $blog_url;
      ?>
      <?php
        $article["comments"] = $item->comments;
        $article["timestamp"] = strtotime($item->pubDate);
      ?>
        <ul class="pageitem">
<li class="textbox"><span class="header"> <?php echo $article["title"] = $item->title;?></span>
        <?php echo $article["description"] = (string) trim($item->description);?>
        </li>
<li class="menu">
<a href="<?php echo $article["link"] = $item->link;?>">
<img alt="Description" src="thumbs/safari.png" />
<span class="name">View</span>
<span class="comment"><?php echo $article["pubDate"] = $item->pubDate;?></span>
<span class="arrow"></span>
</a>
             </li>
</ul>
<?php
        $article["isPermaLink"] = $item->guid["isPermaLink"];

        // get data held in namespaces
        $content = $item->children($ns["content"]);
        $dc      = $item->children($ns["dc"]);
        $wfw     = $item->children($ns["wfw"]);

        
        foreach ($dc->subject as $subject)
                $article["subject"][] = (string)$subject;

        $article["content"] = (string)trim($content->encoded);
        $article["commentRss"] = $wfw->commentRss;

        // add this article to the list
        $articles[$article["timestamp"]] = $article;
}

// at this point, $channel contains all the metadata about the RSS feed,
// and $articles contains an array of articles for us to repurpose
   
   
   
   ?>