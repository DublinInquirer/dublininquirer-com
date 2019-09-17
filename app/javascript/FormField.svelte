<script>
  let type = 'text';
  let name = 'name';
  let value = 'value';
  let errors = ['nice'];
</script>

<style>
</style>

<div class="field {type}">
  <slot></slot>

  <div class="error">
    {errors}
  </div>
</div>