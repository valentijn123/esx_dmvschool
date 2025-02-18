// App.svelte
<script>
  import { onMount } from 'svelte';
  import Questionnaire from './components/Questionnaire.svelte';
  
  let showContainer = false;
  let showMain = false;
  
  onMount(() => {
    window.addEventListener('message', (event) => {
      const item = event.data;
      
      if (item.openQuestion) {
        showContainer = true;
        showMain = true;
      }
      // Add other event handlers
    });
  });
</script>

{#if showContainer}
  <div class="question-container">
    {#if showMain}
      <Questionnaire />
    {/if}
  </div>
{/if}