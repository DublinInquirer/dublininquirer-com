<script>
  export let name;
  export let value;
  export let errors;
</script>

<style>
</style>

<div class="field {type}">
  <label>{name}</label>
  <slot></slot>

  <div class="error">
    {errors}
  </div>
</div>