---
hide:
  - toc
---

<div id="swagger-ui"></div>

<script type="text/javascript">

    window.onload = function() {
      // Begin Swagger UI call region
      const ui = SwaggerUIBundle({
        url: "../../server/openapi.yaml",
        dom_id: '#swagger-ui',
        deepLinking: true,
        docExpansion: 'none',
        presets: [
          SwaggerUIBundle.presets.apis,
          SwaggerUIStandalonePreset
        ],
        plugins: [
          SwaggerUIBundle.plugins.DownloadUrl
        ],
        layout: "StandaloneLayout"
      })
      // End Swagger UI call region
      window.ui = ui
    }
</script>
