<script lang="ts">
  import { onMount } from 'svelte';
  import { fade, scale } from 'svelte/transition';

  let visible = false; // Start with UI hidden
  let currentQuestion = 0;
  let isDev = import.meta.env.DEV; // Check if we're in development mode
  
  let questions = [
    {
      question: "Wat moet je doen als je 's nachts verblind wordt door tegemoetkomend verkeer?",
      image: "https://cdn.discordapp.com/attachments/737689573181751377/1338641132854181898/Schermafbeelding_2025-02-10_232417.png?ex=67b50cb4&is=67b3bb34&hm=2da2633a9ab770346bd863d3a972b86315698153195b0e5988e8a4fb4b2bf1ec&",
      answers: [
        "Rechtuit kijken",
        "Je ogen sluiten",
        "Naar de rechterkant van de weg kijken",
        "Naar de linkerkant van de weg kijken"
      ],
      correct: 2
    },
    {
      question: "Wat is de maximumsnelheid in een woonwijk?",
      image: "https://cdn.discordapp.com/attachments/737689573181751377/1338641132854181898/Schermafbeelding_2025-02-10_232417.png?ex=67b50cb4&is=67b3bb34&hm=2da2633a9ab770346bd863d3a972b86315698153195b0e5988e8a4fb4b2bf1ec&",
      answers: [
        "50 km/u",
        "80 km/u",
        "120 km/u",
        "30 km/u"
      ],
      correct: 0
    }
  ];

  let selectedAnswer: number | null = null;
  let score = 0;

  function handleAnswer() {
    if (selectedAnswer === null) return;
    
    if (selectedAnswer === questions[currentQuestion].correct) {
      score++;
    }

    if (currentQuestion < questions.length - 1) {
      currentQuestion++;
      selectedAnswer = null;
    } else {
      const passed = (score / questions.length) >= 0.7;
      if (window.invokeNative) {
        fetch(`https://${GetParentResourceName()}/close`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ passed })
        });
      }
    }
  }

  function resetExam() {
    currentQuestion = 0;
    selectedAnswer = null;
    score = 0;
  }

  onMount(() => {
    window.addEventListener('message', (event) => {
      if (event.data.openQuestion) {
        visible = true;
      }
    });

    // For development only
    window.addEventListener('keydown', (event) => {
      if (event.key === 'Escape') {
        visible = false;
      }
    });
  });
</script>

{#if isDev}
  <div class="fixed top-4 right-4 z-50 flex gap-2">
    <button 
      class="px-4 py-2 bg-[#00003c] text-white rounded-md text-sm hover:bg-[#00003c]/90 transition-colors"
      on:click={() => {
        visible = true;
        resetExam();
      }}
    >
      Open Examen
    </button>
    <button 
      class="px-4 py-2 bg-[#00003c] text-white rounded-md text-sm hover:bg-[#00003c]/90 transition-colors"
      on:click={() => visible = false}
    >
      Sluit Examen
    </button>
  </div>
{/if}

{#if visible}
  <div class="fixed inset-0 bg-black/50 backdrop-blur-sm z-40"
    transition:fade={{ duration: 200 }}
  >
    <div class="min-h-screen flex items-center justify-center p-6"
      in:scale={{ duration: 200, start: 0.95 }}
      out:scale={{ duration: 200, start: 1 }}
    >
      <div class="w-full max-w-4xl">
        <div class="bg-[#00003c] rounded-lg overflow-hidden shadow-xl">
          {#if questions[currentQuestion].image}
            <div class="h-80 border-b border-white/10">
              <img 
                src={questions[currentQuestion].image} 
                alt="Vraag illustratie"
                class="w-full h-full object-cover"
              />
            </div>
          {/if}

          <div class="px-8 py-6">
            <div class="flex items-center justify-between mb-10">
              <div class="space-y-1">
                <h1 class="text-lg font-medium text-white">Rijbewijs Theorie Examen</h1>
                <p class="text-sm text-blue-200/70">Kies het juiste antwoord om door te gaan</p>
              </div>
              <div class="flex items-center gap-2 text-sm text-blue-200/70">
                <span class="text-white font-medium">{currentQuestion + 1}</span>
                <span class="text-blue-200/40">/</span>
                <span>{questions.length}</span>
              </div>
            </div>

            <div class="mb-8">
              <h2 class="text-lg text-white font-medium leading-relaxed">
                {questions[currentQuestion].question}
              </h2>
            </div>
          
            <div class="space-y-3">
              {#each questions[currentQuestion].answers as answer, i}
                <button 
                  class="group w-full px-4 py-3 text-left rounded-md text-white text-sm transition-all
                    {selectedAnswer === i 
                      ? 'bg-[#a731fd]/20 ring-1 ring-[#a731fd]' 
                      : 'bg-white/5 hover:bg-[#2cc2fa]/5 hover:ring-1 hover:ring-[#2cc2fa]/50'}"
                  on:click={() => selectedAnswer = i}
                >
                  <div class="flex items-center gap-3">
                    <div class="w-4 h-4 rounded-full flex items-center justify-center border
                      {selectedAnswer === i 
                        ? 'border-[#a731fd]' 
                        : 'border-white/30 group-hover:border-[#2cc2fa]/70'}
                    ">
                      {#if selectedAnswer === i}
                        <div class="w-2 h-2 rounded-full bg-[#a731fd]"></div>
                      {/if}
                    </div>
                    {answer}
                  </div>
                </button>
              {/each}
            </div>

            <div class="mt-8 flex justify-end">
              <button 
                class="px-6 py-2.5 rounded-md text-sm transition-colors
                  {selectedAnswer === null 
                    ? 'bg-white/5 text-white/30 cursor-not-allowed' 
                    : 'bg-[#a731fd] text-white hover:bg-[#a731fd]/90 font-medium'}"
                on:click={handleAnswer} 
                disabled={selectedAnswer === null}
              >
                {currentQuestion === questions.length - 1 ? 'Afronden' : 'Volgende'}
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
{/if}
