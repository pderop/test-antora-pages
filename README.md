# test-antora-pages
Antora Test (GH pages)

{% raw %}
{% assign data = site.data.result %}
{% for item in data %}
- **{{ item.name }}**: {{ item.value }} {{ item.unit }}
{% endfor %}
{% endraw %}

