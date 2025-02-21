<script>
  import '../app.css';
</script>

<div class="bg-transparent">
  <slot />
</div>

<style>
  :global(body) {
    background: transparent !important;
    margin: 0;
    padding: 0;
  }

  :global(html) {
    background: transparent !important;
  }
</style>