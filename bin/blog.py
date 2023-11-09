#!/usr/bin/env python3

import os
import re
import markdown2
from xml.sax.saxutils import escape

# Define variables
directory = "posts"
output_directory = "docs/blog"
feed_title = "Endataboss"
feed_description = "Thoughts on building Endatabas"
feed_file = "docs/blog/rss_feed.xml"

# Remove the old feed file if it exists
if os.path.exists(feed_file):
    os.remove(feed_file)

# Initialize the RSS feed
with open(feed_file, "w") as f:
    f.write(f'''<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
<channel>
  <title>{feed_title}</title>
  <description>{feed_description}</description>
  <link>http://www.endatabas.com/blog/rss_feed.xml</link>
  <lastBuildDate>{os.popen('date -R').read().strip()}</lastBuildDate>
  <pubDate>{os.popen('date -R').read().strip()}</pubDate>
  <ttl>1800</ttl>
''')

# Convert each Markdown file to HTML and add it to the RSS feed
for file in os.listdir(directory):
    if file.endswith(".md"):
        name = os.path.splitext(file)[0]
        with open(os.path.join(directory, file), "r") as md_file:
            content = md_file.read()
            title_match = re.search(r"^# (.+)$", content, re.MULTILINE)
            if title_match:
                title = title_match.group(1)
            else:
                title = os.path.splitext(file)[0]
            html_content = markdown2.markdown(content)
            with open(os.path.join(output_directory, f"{name}.html"), "w") as html_file:
                html_file.write(html_content)
            with open(feed_file, "a") as f:
                f.write(f'''<item>
    <title>{title}</title>
    <description><![CDATA[{html_content}]]></description>
    <pubDate>{os.popen(f"date -R -r {os.path.join(directory, file)}").read().strip()}</pubDate>
    <link>http://www.endatabas.com/blog/{name}.html</link>
    <guid>http://www.endatabas.com/blog/{name}.html</guid>
  </item>
''')

# Finalize the RSS feed
with open(feed_file, "a") as f:
    f.write('''</channel>
</rss>''')

print(f"RSS feed generated at {feed_file}")
