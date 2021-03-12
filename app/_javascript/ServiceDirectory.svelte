<script>
  export let services;
</script>

<ul>
  {#each services as { hashed_id, description, title, areas, address_line_1, address_line_2, address_city, address_county, address_postcode, contact_name, contact_number, contact_email, contact_url, categories }}
    <li>
      <h3>{title}</h3>
    </li>
  {/each}
</ul>