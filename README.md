# test-antora-pages
Antora Test (GH pages)

{% for member in site.data.result %}
  <li>
    <a href="https://github.com/{{ member.github }}">
      {{ member.name }}
    </a>
  </li>
{% endfor %}


