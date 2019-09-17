<script>
  import FormField from './FormField.svelte';

  async function handleSubmit(event) {
    console.log(event);
  }
</script>

<style>
</style>

<form on:submit|preventDefault="{handleSubmit}" class="subscription-form">
  <div class="block -form">
    <div class="block -b -p2 -my2 -bg-faint">
      <div class="block -mb2 -pb1 -bb">
        <h3 class="c -w8">Account details</h3>
      </div>
      <FormField>
        <input type="text" value="pumpkin juice">
      </FormField>
    </div>
    <nav class="block -mt2 actions">
      <button class="button -standard -big">Subscribe</button>
    </nav>
  </div>
</form>