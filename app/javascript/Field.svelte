<script>
  export let label, error;
</script>

<style></style>

<div class="field">
  <label>{label}</label>
  <slot></slot>
  {#if error}
    <div class="error">{error}</div>
  {/if}
</div>