<script>
  export let errorMessage;
</script>

<style></style>

<label>Payment details</label>
<div id="card"></div>
{#if errorMessage}
  <div class="error">{errorMessage}</div>
{/if}