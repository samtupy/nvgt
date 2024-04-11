---
layout: default.liquid
title: Blog
permalink: /blog
---

# {{ collections.posts.title }}
{{ collections.posts.description }}
<a href="{{ collections.posts.rss }}">RSS</a>
## posts
{% for post in collections.posts.pages %}
### [{{ post.title }}]({{ post.permalink }})
on {{ post.published_date | date: "%A, %B %d %Y at %r" }}

{{ post.excerpt | strip_html }}

{% endfor %}
