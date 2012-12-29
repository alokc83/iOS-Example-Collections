
  
  

  


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
  <head>
    <meta http-equiv="content-type" content="text/html;charset=UTF-8" />
    <meta http-equiv="X-UA-Compatible" content="chrome=1">
        <title>security/SFHFKeychainUtils.h at master from ldandersen's scifihifi-iphone - GitHub</title>
    <link rel="search" type="application/opensearchdescription+xml" href="/opensearch.xml" title="GitHub" />
    <link rel="fluid-icon" href="http://github.com/fluidicon.png" title="GitHub" />

    <link href="http://assets1.github.com/stylesheets/bundle_common.css?e8150f4f55b1b43dc9b481c953fb02c2b4ec4422" media="screen" rel="stylesheet" type="text/css" />
<link href="http://assets1.github.com/stylesheets/bundle_github.css?e8150f4f55b1b43dc9b481c953fb02c2b4ec4422" media="screen" rel="stylesheet" type="text/css" />

    <script type="text/javascript" charset="utf-8">
      var GitHub = {}
      var github_user = null
      
    </script>
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js" type="text/javascript"></script>
    <script src="http://assets3.github.com/javascripts/bundle_common.js?e8150f4f55b1b43dc9b481c953fb02c2b4ec4422" type="text/javascript"></script>
<script src="http://assets0.github.com/javascripts/bundle_github.js?e8150f4f55b1b43dc9b481c953fb02c2b4ec4422" type="text/javascript"></script>

        <script type="text/javascript" charset="utf-8">
      GitHub.spy({
        repo: "ldandersen/scifihifi-iphone"
      })
    </script>

    
  
    
  

  <link href="http://github.com/ldandersen/scifihifi-iphone/commits/master.atom" rel="alternate" title="Recent Commits to scifihifi-iphone:master" type="application/atom+xml" />

        <meta name="description" content="Open source iPhone code" />
    <script type="text/javascript">
      GitHub.nameWithOwner = GitHub.nameWithOwner || "ldandersen/scifihifi-iphone";
      GitHub.currentRef = "master";
    </script>
  

            <script type="text/javascript">
      var _gaq = _gaq || [];
      _gaq.push(['_setAccount', 'UA-3769691-2']);
      _gaq.push(['_trackPageview']);
      (function() {
        var ga = document.createElement('script');
        ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
        ga.setAttribute('async', 'true');
        document.documentElement.firstChild.appendChild(ga);
      })();
    </script>

  </head>

  

  <body>
    
    

    

    <div class="subnavd" id="main">
      <div id="header" class="pageheaded">
        <div class="site">
          <div class="logo">
            <a href="http://github.com"><img src="/images/modules/header/logov3.png" alt="github" /></a>
          </div>
          
          <div class="topsearch">
  
    <form action="/search" id="top_search_form" method="get">
      <a href="/search" class="advanced-search tooltipped downwards" title="Advanced Search">Advanced Search</a>
      <input type="search" class="search my_repos_autocompleter" name="q" results="5" placeholder="Search&hellip;" /> <input type="submit" value="Search" class="button" />
      <input type="hidden" name="type" value="Everything" />
      <input type="hidden" name="repo" value="" />
      <input type="hidden" name="langOverride" value="" />
      <input type="hidden" name="start_value" value="1" />
    </form>
  
  
    <ul class="nav logged_out">
      
        <li><a href="http://github.com">Home</a></li>
        <li class="pricing"><a href="/plans">Pricing and Signup</a></li>
        <li><a href="http://github.com/explore">Explore GitHub</a></li>
        
        <li><a href="/blog">Blog</a></li>
      
      <li><a href="https://github.com/login">Login</a></li>
    </ul>
  
</div>

        </div>
      </div>

      
      
        
    <div class="site">
      <div class="pagehead repohead vis-public   ">
        <h1>
          <a href="/ldandersen">ldandersen</a> / <strong><a href="http://github.com/ldandersen/scifihifi-iphone">scifihifi-iphone</a></strong>
          
          
        </h1>

        
    <ul class="actions">
      
      
        <li class="for-owner" style="display:none"><a href="https://github.com/ldandersen/scifihifi-iphone/edit" class="minibutton btn-admin "><span><span class="icon"></span>Admin</span></a></li>
        <li>
          <a href="/ldandersen/scifihifi-iphone/toggle_watch" class="minibutton btn-watch " id="watch_button" style="display:none"><span><span class="icon"></span>Watch</span></a>
          <a href="/ldandersen/scifihifi-iphone/toggle_watch" class="minibutton btn-watch " id="unwatch_button" style="display:none"><span><span class="icon"></span>Unwatch</span></a>
        </li>
        
          <li class="for-notforked" style="display:none"><a href="/ldandersen/scifihifi-iphone/fork" class="minibutton btn-fork " id="fork_button" onclick="var f = document.createElement('form'); f.style.display = 'none'; this.parentNode.appendChild(f); f.method = 'POST'; f.action = this.href;var s = document.createElement('input'); s.setAttribute('type', 'hidden'); s.setAttribute('name', 'authenticity_token'); s.setAttribute('value', '0fd486248cf5b3bebb7ee62723570d65551b82fc'); f.appendChild(s);f.submit();return false;"><span><span class="icon"></span>Fork</span></a></li>
          <li class="for-hasfork" style="display:none"><a href="#" class="minibutton btn-fork " id="your_fork_button"><span><span class="icon"></span>Your Fork</span></a></li>
          <li id="pull_request_item" style="display:none"><a href="/ldandersen/scifihifi-iphone/pull_request/" class="minibutton btn-pull-request "><span><span class="icon"></span>Pull Request</span></a></li>
          <li><a href="#" class="minibutton btn-download " id="download_button"><span><span class="icon"></span>Download Source</span></a></li>
        
      
      <li class="repostats">
        <ul class="repo-stats">
          <li class="watchers"><a href="/ldandersen/scifihifi-iphone/watchers" title="Watchers" class="tooltipped downwards">236</a></li>
          <li class="forks"><a href="/ldandersen/scifihifi-iphone/network" title="Forks" class="tooltipped downwards">14</a></li>
        </ul>
      </li>
    </ul>


        <ul class="tabs">
  <li><a href="http://github.com/ldandersen/scifihifi-iphone/tree/master" class="selected" highlight="repo_source">Source</a></li>
  <li><a href="http://github.com/ldandersen/scifihifi-iphone/commits/master" highlight="repo_commits">Commits</a></li>

  
  <li><a href="/ldandersen/scifihifi-iphone/network" highlight="repo_network">Network (14)</a></li>

  

  
    
    <li><a href="/ldandersen/scifihifi-iphone/issues" highlight="issues">Issues (3)</a></li>
  

  
    
    <li><a href="/ldandersen/scifihifi-iphone/downloads">Downloads (0)</a></li>
  

  
    
    <li><a href="http://wiki.github.com/ldandersen/scifihifi-iphone/">Wiki (1)</a></li>
  

  <li><a href="/ldandersen/scifihifi-iphone/graphs" highlight="repo_graphs">Graphs</a></li>

  <li class="contextswitch nochoices">
    <span class="toggle leftwards" >
      <em>Branch:</em>
      <code>master</code>
    </span>
  </li>
</ul>

<div style="display:none" id="pl-description"><p><em class="placeholder">click here to add a description</em></p></div>
<div style="display:none" id="pl-homepage"><p><em class="placeholder">click here to add a homepage</em></p></div>

<div class="subnav-bar">
  
  <ul>
    <li>
      <a href="#" class="dropdown">Switch Branches (1)</a>
      <ul>
        
          
            <li><strong>master &#x2713;</strong></li>
            
      </ul>
    </li>
    <li>
      <a href="#" class="dropdown defunct">Switch Tags (0)</a>
      
    </li>
    <li>
    
    <a href="/ldandersen/scifihifi-iphone/branches" class="manage">Branch List</a>
    
    </li>
  </ul>
</div>









        
    <div id="repo_details" class="metabox clearfix ">
      <div id="repo_details_loader" class="metabox-loader" style="display:none">Sending Request&hellip;</div>

      

      <div id="repository_description" rel="repository_description_edit">
        
          <p>Open source iPhone code
            <span id="read_more" style="display:none">&mdash; <a href="#readme">Read more</a></span>
          </p>
        
      </div>
      <div id="repository_description_edit" style="display:none;" class="inline-edit">
        <form action="/ldandersen/scifihifi-iphone/edit/update" method="post"><div style="margin:0;padding:0"><input name="authenticity_token" type="hidden" value="0fd486248cf5b3bebb7ee62723570d65551b82fc" /></div>
          <input type="hidden" name="field" value="repository_description">
          <input type="text" class="textfield" name="value" value="Open source iPhone code">
          <div class="form-actions">
            <button class="minibutton"><span>Save</span></button> &nbsp; <a href="#" class="cancel">Cancel</a>
          </div>
        </form>
      </div>

      
      <div class="repository-homepage" id="repository_homepage" rel="repository_homepage_edit">
        <p><a href="http://" rel="nofollow"></a></p>
      </div>
      <div id="repository_homepage_edit" style="display:none;" class="inline-edit">
        <form action="/ldandersen/scifihifi-iphone/edit/update" method="post"><div style="margin:0;padding:0"><input name="authenticity_token" type="hidden" value="0fd486248cf5b3bebb7ee62723570d65551b82fc" /></div>
          <input type="hidden" name="field" value="repository_homepage">
          <input type="text" class="textfield" name="value" value="">
          <div class="form-actions">
            <button class="minibutton"><span>Save</span></button> &nbsp; <a href="#" class="cancel">Cancel</a>
          </div>
        </form>
      </div>

      <div class="rule "></div>

      <div id="url_box" class="url-box">
        <ul class="clone-urls">
          <li id="private_clone_url" style="display:none"><a href="git@github.com:ldandersen/scifihifi-iphone.git" data-permissions="Read+Write">Private</a></li>
          
            <li id="public_clone_url"><a href="git://github.com/ldandersen/scifihifi-iphone.git" data-permissions="Read-Only">Read-Only</a></li>
            <li id="http_clone_url"><a href="http://github.com/ldandersen/scifihifi-iphone.git" data-permissions="Read-Only">HTTP Read-Only</a></li>
          
        </ul>
        <input type="text" spellcheck="false" id="url_field" class="url-field" />
              <span style="display:none" id="url_box_clippy"></span>
      <span id="clippy_tooltip_url_box_clippy" class="clippy-tooltip tooltipped" title="copy to clipboard">
      <object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000"
              width="14"
              height="14"
              class="clippy"
              id="clippy" >
      <param name="movie" value="/flash/clippy.swf?v5"/>
      <param name="allowScriptAccess" value="always" />
      <param name="quality" value="high" />
      <param name="scale" value="noscale" />
      <param NAME="FlashVars" value="id=url_box_clippy&amp;copied=&amp;copyto=">
      <param name="bgcolor" value="#FFFFFF">
      <param name="wmode" value="opaque">
      <embed src="/flash/clippy.swf?v5"
             width="14"
             height="14"
             name="clippy"
             quality="high"
             allowScriptAccess="always"
             type="application/x-shockwave-flash"
             pluginspage="http://www.macromedia.com/go/getflashplayer"
             FlashVars="id=url_box_clippy&amp;copied=&amp;copyto="
             bgcolor="#FFFFFF"
             wmode="opaque"
      />
      </object>
      </span>

        <p id="url_description">This URL has <strong>Read+Write</strong> access</p>
      </div>
    </div>


        

      </div><!-- /.pagehead -->

      









<script type="text/javascript">
  GitHub.currentCommitRef = "master"
  GitHub.currentRepoOwner = "ldandersen"
  GitHub.currentRepo = "scifihifi-iphone"
  GitHub.downloadRepo = '/ldandersen/scifihifi-iphone/archives/master'
  

  
</script>










  <div id="commit">
    <div class="group">
        
  <div class="envelope commit">
    <div class="human">
      
        <div class="message"><pre><a href="/ldandersen/scifihifi-iphone/commit/7a4047682e9f3ef77ced039a049dc3f021be0799">Fix improper comparing of NSString.</a> </pre></div>
      

      <div class="actor">
        <div class="gravatar">
          
          <img alt="" height="30" src="http://www.gravatar.com/avatar/026700c13fc03e75e103a98c77f57b10?s=30&amp;d=http%3A%2F%2Fgithub.com%2Fimages%2Fgravatars%2Fgravatar-30.png" width="30" />
        </div>
        <div class="name">tomute <span>(author)</span></div>
        <div class="date">
          <abbr class="relatize" title="2010-01-02 23:36:23">Sat Jan 02 23:36:23 -0800 2010</abbr>
        </div>
      </div>

      
        <div class="actor">
          <div class="gravatar">
            <img alt="" height="30" src="http://www.gravatar.com/avatar/84f716c7f1b3b13745bc28c8335602da?s=30&amp;d=http%3A%2F%2Fgithub.com%2Fimages%2Fgravatars%2Fgravatar-30.png" width="30" />
          </div>
          <div class="name">Buzz Andersen <span>(committer)</span></div>
          <div class="date"><abbr class="relatize" title="2010-01-20 09:23:05">Wed Jan 20 09:23:05 -0800 2010</abbr></div>
        </div>
      

    </div>
    <div class="machine">
      <span>c</span>ommit&nbsp;&nbsp;<a href="/ldandersen/scifihifi-iphone/commit/7a4047682e9f3ef77ced039a049dc3f021be0799" hotkey="c">7a4047682e9f3ef77ced039a049dc3f021be0799</a><br />
      <span>t</span>ree&nbsp;&nbsp;&nbsp;&nbsp;<a href="/ldandersen/scifihifi-iphone/tree/7a4047682e9f3ef77ced039a049dc3f021be0799" hotkey="t">0d61d7a89609aa7270d246c0599a0ed6b4455278</a><br />
      
        <span>p</span>arent&nbsp;
        
        <a href="/ldandersen/scifihifi-iphone/tree/d4298f123a06a91acbe8422ddb6164be3dbcff9e" hotkey="p">d4298f123a06a91acbe8422ddb6164be3dbcff9e</a>
      

    </div>
  </div>

    </div>
  </div>



  
    <div id="path">
      <b><a href="/ldandersen/scifihifi-iphone/tree/73315cce1dd8a02117d1f5a492c3699b24b1e2ef">scifihifi-iphone</a></b> / <a href="/ldandersen/scifihifi-iphone/tree/73315cce1dd8a02117d1f5a492c3699b24b1e2ef/security">security</a> / SFHFKeychainUtils.h       <span style="display:none" id="clippy_1792">security/SFHFKeychainUtils.h</span>
      
      <object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000"
              width="110"
              height="14"
              class="clippy"
              id="clippy" >
      <param name="movie" value="/flash/clippy.swf?v5"/>
      <param name="allowScriptAccess" value="always" />
      <param name="quality" value="high" />
      <param name="scale" value="noscale" />
      <param NAME="FlashVars" value="id=clippy_1792&amp;copied=copied!&amp;copyto=copy to clipboard">
      <param name="bgcolor" value="#FFFFFF">
      <param name="wmode" value="opaque">
      <embed src="/flash/clippy.swf?v5"
             width="110"
             height="14"
             name="clippy"
             quality="high"
             allowScriptAccess="always"
             type="application/x-shockwave-flash"
             pluginspage="http://www.macromedia.com/go/getflashplayer"
             FlashVars="id=clippy_1792&amp;copied=copied!&amp;copyto=copy to clipboard"
             bgcolor="#FFFFFF"
             wmode="opaque"
      />
      </object>
      

    </div>

    <div id="files">
      <div class="file">
        <div class="meta">
          <div class="info">
            <span>100644</span>
            <span>42 lines (35 sloc)</span>
            <span>1.821 kb</span>
          </div>
          <div class="actions">
            
              <a style="display:none;" id="file-edit-link" href="#" rel="/ldandersen/scifihifi-iphone/file-edit/__ref__/security/SFHFKeychainUtils.h">edit</a>
            
            <a href="/ldandersen/scifihifi-iphone/raw/73315cce1dd8a02117d1f5a492c3699b24b1e2ef/security/SFHFKeychainUtils.h" id="raw-url">raw</a>
            
              <a href="/ldandersen/scifihifi-iphone/blame/73315cce1dd8a02117d1f5a492c3699b24b1e2ef/security/SFHFKeychainUtils.h">blame</a>
            
            <a href="/ldandersen/scifihifi-iphone/commits/master/security/SFHFKeychainUtils.h">history</a>
          </div>
        </div>
        
  <div class="data syntax type-cpp">
    
      <table cellpadding="0" cellspacing="0">
        <tr>
          <td>
            
            <pre class="line_numbers">
<span id="LID1" rel="#L1">1</span>
<span id="LID2" rel="#L2">2</span>
<span id="LID3" rel="#L3">3</span>
<span id="LID4" rel="#L4">4</span>
<span id="LID5" rel="#L5">5</span>
<span id="LID6" rel="#L6">6</span>
<span id="LID7" rel="#L7">7</span>
<span id="LID8" rel="#L8">8</span>
<span id="LID9" rel="#L9">9</span>
<span id="LID10" rel="#L10">10</span>
<span id="LID11" rel="#L11">11</span>
<span id="LID12" rel="#L12">12</span>
<span id="LID13" rel="#L13">13</span>
<span id="LID14" rel="#L14">14</span>
<span id="LID15" rel="#L15">15</span>
<span id="LID16" rel="#L16">16</span>
<span id="LID17" rel="#L17">17</span>
<span id="LID18" rel="#L18">18</span>
<span id="LID19" rel="#L19">19</span>
<span id="LID20" rel="#L20">20</span>
<span id="LID21" rel="#L21">21</span>
<span id="LID22" rel="#L22">22</span>
<span id="LID23" rel="#L23">23</span>
<span id="LID24" rel="#L24">24</span>
<span id="LID25" rel="#L25">25</span>
<span id="LID26" rel="#L26">26</span>
<span id="LID27" rel="#L27">27</span>
<span id="LID28" rel="#L28">28</span>
<span id="LID29" rel="#L29">29</span>
<span id="LID30" rel="#L30">30</span>
<span id="LID31" rel="#L31">31</span>
<span id="LID32" rel="#L32">32</span>
<span id="LID33" rel="#L33">33</span>
<span id="LID34" rel="#L34">34</span>
<span id="LID35" rel="#L35">35</span>
<span id="LID36" rel="#L36">36</span>
<span id="LID37" rel="#L37">37</span>
<span id="LID38" rel="#L38">38</span>
<span id="LID39" rel="#L39">39</span>
<span id="LID40" rel="#L40">40</span>
<span id="LID41" rel="#L41">41</span>
<span id="LID42" rel="#L42">42</span>
</pre>
          </td>
          <td width="100%">
            
              <div class="highlight"><pre><div class="line" id="LC1"><span class="c1">//</span></div><div class="line" id="LC2"><span class="c1">//  SFHFKeychainUtils.h</span></div><div class="line" id="LC3"><span class="c1">//</span></div><div class="line" id="LC4"><span class="c1">//  Created by Buzz Andersen on 10/20/08.</span></div><div class="line" id="LC5"><span class="c1">//  Based partly on code by Jonathan Wight, Jon Crosby, and Mike Malone.</span></div><div class="line" id="LC6"><span class="c1">//  Copyright 2008 Sci-Fi Hi-Fi. All rights reserved.</span></div><div class="line" id="LC7"><span class="c1">//</span></div><div class="line" id="LC8"><span class="c1">//  Permission is hereby granted, free of charge, to any person</span></div><div class="line" id="LC9"><span class="c1">//  obtaining a copy of this software and associated documentation</span></div><div class="line" id="LC10"><span class="c1">//  files (the &quot;Software&quot;), to deal in the Software without</span></div><div class="line" id="LC11"><span class="c1">//  restriction, including without limitation the rights to use,</span></div><div class="line" id="LC12"><span class="c1">//  copy, modify, merge, publish, distribute, sublicense, and/or sell</span></div><div class="line" id="LC13"><span class="c1">//  copies of the Software, and to permit persons to whom the</span></div><div class="line" id="LC14"><span class="c1">//  Software is furnished to do so, subject to the following</span></div><div class="line" id="LC15"><span class="c1">//  conditions:</span></div><div class="line" id="LC16"><span class="c1">//</span></div><div class="line" id="LC17"><span class="c1">//  The above copyright notice and this permission notice shall be</span></div><div class="line" id="LC18"><span class="c1">//  included in all copies or substantial portions of the Software.</span></div><div class="line" id="LC19"><span class="c1">//</span></div><div class="line" id="LC20"><span class="c1">//  THE SOFTWARE IS PROVIDED &quot;AS IS&quot;, WITHOUT WARRANTY OF ANY KIND,</span></div><div class="line" id="LC21"><span class="c1">//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES</span></div><div class="line" id="LC22"><span class="c1">//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND</span></div><div class="line" id="LC23"><span class="c1">//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT</span></div><div class="line" id="LC24"><span class="c1">//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,</span></div><div class="line" id="LC25"><span class="c1">//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING</span></div><div class="line" id="LC26"><span class="c1">//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR</span></div><div class="line" id="LC27"><span class="c1">//  OTHER DEALINGS IN THE SOFTWARE.</span></div><div class="line" id="LC28"><span class="c1">//</span></div><div class="line" id="LC29">&nbsp;</div><div class="line" id="LC30"><span class="cp">#import &lt;UIKit/UIKit.h&gt;</span></div><div class="line" id="LC31">&nbsp;</div><div class="line" id="LC32">&nbsp;</div><div class="line" id="LC33"><span class="err">@</span><span class="n">interface</span> <span class="n">SFHFKeychainUtils</span> <span class="o">:</span> <span class="n">NSObject</span> <span class="p">{</span></div><div class="line" id="LC34">&nbsp;</div><div class="line" id="LC35"><span class="p">}</span></div><div class="line" id="LC36">&nbsp;</div><div class="line" id="LC37"><span class="o">+</span> <span class="p">(</span><span class="n">NSString</span> <span class="o">*</span><span class="p">)</span> <span class="nl">getPasswordForUsername:</span> <span class="p">(</span><span class="n">NSString</span> <span class="o">*</span><span class="p">)</span> <span class="n">username</span> <span class="nl">andServiceName:</span> <span class="p">(</span><span class="n">NSString</span> <span class="o">*</span><span class="p">)</span> <span class="n">serviceName</span> <span class="nl">error:</span> <span class="p">(</span><span class="n">NSError</span> <span class="o">**</span><span class="p">)</span> <span class="n">error</span><span class="p">;</span></div><div class="line" id="LC38"><span class="o">+</span> <span class="p">(</span><span class="kt">void</span><span class="p">)</span> <span class="nl">storeUsername:</span> <span class="p">(</span><span class="n">NSString</span> <span class="o">*</span><span class="p">)</span> <span class="n">username</span> <span class="nl">andPassword:</span> <span class="p">(</span><span class="n">NSString</span> <span class="o">*</span><span class="p">)</span> <span class="n">password</span> <span class="nl">forServiceName:</span> <span class="p">(</span><span class="n">NSString</span> <span class="o">*</span><span class="p">)</span> <span class="n">serviceName</span> <span class="nl">updateExisting:</span> <span class="p">(</span><span class="n">BOOL</span><span class="p">)</span> <span class="n">updateExisting</span> <span class="nl">error:</span> <span class="p">(</span><span class="n">NSError</span> <span class="o">**</span><span class="p">)</span> <span class="n">error</span><span class="p">;</span></div><div class="line" id="LC39"><span class="o">+</span> <span class="p">(</span><span class="kt">void</span><span class="p">)</span> <span class="nl">deleteItemForUsername:</span> <span class="p">(</span><span class="n">NSString</span> <span class="o">*</span><span class="p">)</span> <span class="n">username</span> <span class="nl">andServiceName:</span> <span class="p">(</span><span class="n">NSString</span> <span class="o">*</span><span class="p">)</span> <span class="n">serviceName</span> <span class="nl">error:</span> <span class="p">(</span><span class="n">NSError</span> <span class="o">**</span><span class="p">)</span> <span class="n">error</span><span class="p">;</span></div><div class="line" id="LC40">&nbsp;</div><div class="line" id="LC41"><span class="err">@</span><span class="n">end</span></div><div class="line" id="LC42">&nbsp;</div></pre></div>
            
          </td>
        </tr>
      </table>
    
  </div>


      </div>
    </div>

  


    </div>
  
      

      <div class="push"></div>
    </div>

    <div id="footer">
      <div class="site">
        <div class="info">
          <div class="links">
            <a href="http://github.com/blog"><b>Blog</b></a> |
            <a href="http://support.github.com/">Support</a> |
            <a href="http://github.com/training">Training</a> |
            <a href="http://github.com/contact">Contact</a> |
            <a href="http://develop.github.com">API</a> |
            <a href="http://status.github.com">Status</a> |
            <a href="http://twitter.com/github">Twitter</a> |
            <a href="http://help.github.com">Help</a> |
            <a href="http://github.com/security">Security</a>
          </div>
          <div class="company">
            &copy;
            2010
            <span id="_rrt" title="0.07173s from fe2.rs.github.com">GitHub</span> Inc.
            All rights reserved. |
            <a href="/site/terms">Terms of Service</a> |
            <a href="/site/privacy">Privacy Policy</a>
          </div>
        </div>
        <div class="sponsor">
          <div>
            Powered by the <a href="http://www.rackspace.com ">Dedicated
            Servers</a> and<br/> <a href="http://www.rackspacecloud.com">Cloud
            Computing</a> of Rackspace Hosting<span>&reg;</span>
          </div>
          <a href="http://www.rackspace.com">
            <img alt="Dedicated Server" src="http://assets0.github.com/images/modules/footer/rackspace_logo.png?e8150f4f55b1b43dc9b481c953fb02c2b4ec4422" />
          </a>
        </div>
      </div>
    </div>

    <script>window._auth_token = "0fd486248cf5b3bebb7ee62723570d65551b82fc"</script>
    
    
  </body>
</html>

