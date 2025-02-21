<script lang="ts">
  import { onMount } from 'svelte';
  import { fade, scale, fly } from 'svelte/transition';
  import { cubicOut } from 'svelte/easing';
  import { tweened } from 'svelte/motion';
  import { 
    Car, 
    Ship, 
    Bike, 
    Truck, 
    HelpCircle, 
    CheckCircle2, 
    ArrowRight, 
    HelpCircle as CircleQuestion // Alias HelpCircle as CircleQuestion
  } from 'lucide-svelte';

  // Add question sets for different categories
  const questionSets = {
    dmv: [
      {
        question: "Je rijdt in de regen op de snelweg. Wat moet je doen?",
        image: "img/rain_highway.jpg",
        answers: [
          "Snelheid verhogen om snel thuis te zijn",
          "Afstand verkleinen tot voorligger",
          "Snelheid verminderen en meer afstand houden",
          "Alarmlichten aanzetten"
        ],
        correct: 2
      },
      {
        question: "Wat is de maximumsnelheid binnen de bebouwde kom?",
        answers: [
          "30 km/u",
          "50 km/u",
          "60 km/u",
          "70 km/u"
        ],
        correct: 1
      },
      {
        question: "Wat is de juiste volgorde bij het maken van een bocht?",
        image: "img/corner.jpg",
        answers: [
          "Gas geven, sturen, remmen",
          "Remmen, gas geven, sturen",
          "Remmen, sturen, gas geven",
          "Sturen, remmen, gas geven"
        ],
        correct: 2
      },
      {
        question: "Wat is de minimale profieldiepte van autobanden?",
        answers: [
          "1.6 mm",
          "2.0 mm",
          "2.5 mm",
          "3.0 mm"
        ],
        correct: 0
      },
      {
        question: "Je nadert deze kruising. Wie heeft er voorrang?",
        image: "img/intersection.jpg",
        answers: [
          "Jij hebt voorrang",
          "De auto van rechts",
          "De snelste heeft voorrang",
          "Grootste voertuig heeft voorrang"
        ],
        correct: 1
      },
      {
        question: "Wanneer moet je groot licht dimmen?",
        answers: [
          "Bij regen",
          "Bij tegemoetkomend verkeer",
          "In de bebouwde kom",
          "Alle bovenstaande antwoorden"
        ],
        correct: 3
      },
      {
        question: "Hoe check je of je banden de juiste spanning hebben?",
        image: "img/tire_pressure.jpg",
        answers: [
          "Door er tegenaan te schoppen",
          "Met een bandenspanningsmeter",
          "Door er naar te kijken",
          "Door er op te duwen"
        ],
        correct: 1
      },
      {
        question: "Hoe groot moet de minimale volgafstand zijn bij droog weer?",
        answers: [
          "1 seconde",
          "2 seconden",
          "3 seconden",
          "4 seconden"
        ],
        correct: 1
      },
      {
        question: "Wat moet je doen bij aquaplaning?",
        image: "img/aquaplaning.jpg",
        answers: [
          "Gas loslaten en rechtuit sturen",
          "Hard remmen",
          "Snel uitwijken",
          "Gas bijgeven"
        ],
        correct: 0
      },
      {
        question: "Wanneer gebruik je je alarmlichten?",
        answers: [
          "Als je dubbel geparkeerd staat",
          "Bij gevaar of een noodstop",
          "Als je haast hebt",
          "Bij het parkeren"
        ],
        correct: 1
      }
    ],
    boat: [
      {
        question: "Welke kant moet je uitwijken als je een andere boot tegenkomt?",
        image: "boat1.jpg", 
        answers: [
          "Naar stuurboord (rechts)",
          "Naar bakboord (links)",
          "Maakt niet uit",
          "Rechtdoor varen"
        ],
        correct: 0
      },
      {
        question: "Wat betekent deze vlag op een boot?",
        image: "boat2.jpg",
        answers: [
          "Boot heeft voorrang",
          "Boot heeft duikers te water",
          "Boot is aan het vissen",
          "Boot heeft pech"
        ],
        correct: 1
      }
    ],
    bike: [
      {
        question: "Wat is de juiste beschermende kleding voor op de motor?",
        image: "img/bike_gear.jpg",
        answers: [
          "Alleen een helm is voldoende",
          "Helm, jas en stevige schoenen",
          "Complete motorkleding met bescherming",
          "Gewone spijkerbroek en jas"
        ],
        correct: 2
      },
      {
        question: "Hoe ga je het beste een scherpe bocht door op de motor?",
        image: "img/bike_corner.jpg",
        answers: [
          "Vol gas door de bocht",
          "Remmen in de bocht",
          "Voor de bocht remmen, tijdens gas bijgeven",
          "Leunen tegen de bocht in"
        ],
        correct: 2
      },
      {
        question: "Wat doe je als je voorwiel begint te slippen?",
        answers: [
          "Hard remmen",
          "Gas loslaten en rechtop blijven",
          "Stuur loslaten",
          "Vol gas geven"
        ],
        correct: 1
      },
      {
        question: "Hoe controleer je de ketting van je motor?",
        image: "img/bike_chain.jpg",
        answers: [
          "Alleen visuele inspectie",
          "Controleer spanning en smering",
          "Hoeft niet gecontroleerd te worden",
          "Alleen als hij geluid maakt"
        ],
        correct: 1
      },
      {
        question: "Wat is de beste positie op de weg als motorrijder?",
        answers: [
          "Uiterst links op de rijbaan",
          "Midden op de rijbaan",
          "Links of rechts van het midden van de rijstrook",
          "Zo dicht mogelijk bij de berm"
        ],
        correct: 2
      },
      {
        question: "Hoe reageer je op een glad wegdek?",
        image: "img/wet_road.jpg",
        answers: [
          "Rustig rijden en geen abrupte bewegingen",
          "Snel doorrijden",
          "Hard remmen waar nodig",
          "Schuin door bochten"
        ],
        correct: 0
      },
      {
        question: "Wanneer moet je extra afstand houden als motorrijder?",
        answers: [
          "Alleen bij regen",
          "Alleen in bochten",
          "Bij alle weersomstandigheden",
          "Alleen op de snelweg"
        ],
        correct: 2
      },
      {
        question: "Hoe parkeer je een motor op een helling?",
        image: "img/bike_parking.jpg",
        answers: [
          "In eerste versnelling, wiel recht",
          "In zijn vrij, standaard uit",
          "In eerste versnelling, wiel naar links",
          "Maakt niet uit hoe"
        ],
        correct: 0
      },
      {
        question: "Wat is belangrijk bij het inhalen met een motor?",
        answers: [
          "Zo snel mogelijk inhalen",
          "Dode hoek checken en veilige afstand",
          "Dicht op voorligger blijven",
          "Claxonneren bij inhalen"
        ],
        correct: 1
      },
      {
        question: "Hoe ga je om met sterke zijwind op de motor?",
        image: "img/side_wind.jpg",
        answers: [
          "Snelheid verhogen",
          "Naar de wind toe leunen",
          "Van de wind af leunen",
          "Rechtop blijven en snelheid aanpassen"
        ],
        correct: 3
      }
    ],
    truck: [
      {
        question: "Wat is de maximale hoogte voor een vrachtwagen?",
        image: "img/truck_height.jpg",
        answers: [
          "4 meter",
          "4.5 meter",
          "5 meter",
          "3.5 meter"
        ],
        correct: 0
      },
      {
        question: "Hoe vaak moet je verplicht rusten als vrachtwagenchauffeur?",
        answers: [
          "Elke 2 uur 15 minuten",
          "Elke 4 uur 30 minuten",
          "Elke 4.5 uur 45 minuten",
          "Elke 6 uur 60 minuten"
        ],
        correct: 2
      },
      {
        question: "Wat doe je als je lading begint te schuiven?",
        image: "img/truck_cargo.jpg",
        answers: [
          "Direct hard remmen",
          "Rustig vaart minderen en veilig stoppen",
          "Doorrijden naar bestemming",
          "Snelheid verhogen"
        ],
        correct: 1
      },
      {
        question: "Wat is de minimale volgafstand voor vrachtwagens?",
        answers: [
          "2 seconden",
          "3 seconden",
          "4 seconden",
          "5 seconden"
        ],
        correct: 2
      },
      {
        question: "Hoe controleer je de lading voor vertrek?",
        image: "img/cargo_check.jpg",
        answers: [
          "Visuele inspectie is voldoende",
          "Complete controle van vastzetmaterialen",
          "Papieren controleren is genoeg",
          "Hoeft niet gecontroleerd te worden"
        ],
        correct: 1
      },
      {
        question: "Wat is de maximumsnelheid voor vrachtwagens op de snelweg?",
        answers: [
          "80 km/u",
          "90 km/u",
          "100 km/u",
          "120 km/u"
        ],
        correct: 0
      },
      {
        question: "Hoe neem je een bocht met een vrachtwagen?",
        image: "img/truck_turn.jpg",
        answers: [
          "Kort door de bocht",
          "Wijd uitdraaien",
          "Zoals met een personenauto",
          "Maakt niet uit"
        ],
        correct: 1
      },
      {
        question: "Wat moet je extra controleren bij mistig weer?",
        answers: [
          "Alleen de verlichting",
          "Verlichting en markering",
          "Alleen de spiegels",
          "Niets extra's"
        ],
        correct: 1
      },
      {
        question: "Hoe ga je om met zijwind?",
        image: "img/truck_wind.jpg",
        answers: [
          "Snelheid verhogen",
          "Snelheid verlagen en stuur corrigeren",
          "Gewoon doorrijden",
          "Direct stoppen"
        ],
        correct: 1
      },
      {
        question: "Wanneer moet je de bandenspanning controleren?",
        answers: [
          "Alleen bij de jaarlijkse keuring",
          "Wekelijks en voor lange ritten",
          "Alleen als ze zacht lijken",
          "Maandelijks is voldoende"
        ],
        correct: 1
      }
    ]
  };

  let visible = false; // Start with UI hidden
  let examState: 'intro' | 'exam' | 'result' = 'intro';
  let currentQuestion = 0;
  
  let testType = 'dmv';
  let questions: any[] = [];

  let selectedAnswer: number | null = null;
  let score = 0;
  let showResult = false;
  const progressTween = tweened(0, {
    duration: 1000,
    easing: cubicOut
  });

  async function handleAnswer() {
    if (selectedAnswer === null) return;
    
    if (selectedAnswer === questions[currentQuestion].correct) {
      score++;
    }

    if (currentQuestion < questions.length - 1) {
      currentQuestion++;
      selectedAnswer = null;
    } else {
      examState = 'result';
      const percentage = (score / questions.length) * 100;
      progressTween.set(percentage);
    }
  }

  function resetExam() {
    currentQuestion = 0;
    selectedAnswer = null;
    score = 0;
  }

  function startExam() {
    examState = 'exam';
    resetExam();
  }

  $: progress = ((currentQuestion + 1) / questions.length) * 100;
  $: passed = (score / questions.length) >= 0.7;

  // Voeg een reactiviteit voor live scaling toe
  let scaleFactor = 1;
  function updateScale() {
    // Als de viewport kleiner is dan 1920x1080, houd scaleFactor op 1
    if (window.innerWidth < 1920 || window.innerHeight < 1080) {
      scaleFactor = 1;
    } else {
      scaleFactor = Math.min(1.8, Math.min(window.innerWidth / 1920, window.innerHeight / 1080));
    }
  }
  onMount(() => {
    updateScale();
    window.addEventListener('resize', updateScale);
    return () => window.removeEventListener('resize', updateScale);
  });

  onMount(() => {
    // Listen for NUI messages
    window.addEventListener('message', (event) => {
      const data = event.data;
      
      if (data.openQuestion === true) {
        testType = data.testType || 'dmv';
        questions = questionSets[testType];
        visible = true;
        examState = 'intro';
        resetExam(); // Reset questions, score, etc.
        selectedAnswer = null;
        showResult = false;
        progressTween.set(0);
      }
      
      if (data.openQuestion === false) {
        visible = false;
      }
    });

    // Make sure UI is hidden on initial load
    visible = false;
  });
</script>

{#if visible}
  <div class="fixed inset-0 z-40">
    <div class="min-h-screen flex items-center justify-center p-6"
      in:scale={{ duration: 200, start: 0.97 }}
      out:scale={{ duration: 150, start: 1 }}
    >
      <!-- Gebruik nu de reactiviteit met scaleFactor, zodat live resizes meeschalen -->
      <div style="transform: scale({scaleFactor}); transform-origin: center;">
        <!-- Wijzig hier de breedte naar een dunnere layout -->
        <div class="w-[680px]">
          <!-- Changed back to brand color with full opacity -->
          <div class="bg-brand-black rounded-xl overflow-hidden">
            <div class="h-[760px] relative"> <!-- Verhoogd van 740px naar 800px -->
              {#if examState === 'intro'}
                <div class="absolute inset-0 flex flex-col items-center justify-center px-8"
                  in:fly={{ y: 10, duration: 200, delay: 50 }}
                  out:fly={{ y: -10, duration: 200 }}
                >
                  <div class="w-full max-w-2xl">
                    <!-- Header Section -->
                    <div class="text-center mb-8">
                      <div class="inline-block p-2 rounded-full bg-brand-purple/10 mb-4">
                        {#if testType === 'dmv'}
                          <Car class="w-8 h-8 text-brand-purple" />
                        {:else if testType === 'boat'}
                          <Ship class="w-8 h-8 text-brand-purple" />
                        {:else if testType === 'bike'}
                          <Bike class="w-8 h-8 text-brand-purple" />
                        {:else if testType === 'truck'}
                          <Truck class="w-8 h-8 text-brand-purple" />
                        {/if}
                      </div>
                      <h1 class="text-4xl font-bold text-white mb-2 tracking-tight">
                        {#if testType === 'dmv'}
                          Auto Theorie Examen
                        {:else if testType === 'boat'}
                          Vaarbewijs Theorie
                        {:else if testType === 'bike'}
                          Motor Theorie Examen
                        {:else if testType === 'truck'}
                          Vrachtwagen Theorie
                        {/if}
                      </h1>
                      <p class="text-white/60">Ben je klaar om je theoretische kennis te testen?</p>
                    </div>

                    <!-- Info Cards Grid -->
                    <div class="grid grid-cols-2 gap-4 mb-8">
                      <div class="bg-gradient-to-br from-brand-purple/10 to-brand-purple/5 rounded-xl p-6 border border-brand-purple/10">
                        <div class="flex items-center gap-4">
                          <div class="p-2 rounded-lg bg-brand-purple/10">
                            <CircleQuestion class="w-6 h-6 text-brand-purple" />
                          </div>
                          <div>
                            <p class="text-sm text-white/60">Aantal vragen</p>
                            <p class="text-xl font-bold text-white">{questions.length}</p>
                          </div>
                        </div>
                      </div>
                      <div class="bg-gradient-to-br from-brand-purple/10 to-brand-purple/5 rounded-xl p-6 border border-brand-purple/10">
                        <div class="flex items-center gap-4">
                          <div class="p-2 rounded-lg bg-brand-purple/10">
                            <CircleQuestion class="w-6 h-6 text-brand-purple" />
                          </div>
                          <div>
                            <p class="text-sm text-white/60">Vereist percentage</p>
                            <p class="text-xl font-bold text-white">70%</p>
                          </div>
                        </div>
                      </div>
                    </div>

                    <!-- Description Card -->
                    <div class="bg-gradient-to-br from-brand-purple/10 to-brand-purple/5 rounded-xl p-6 border border-brand-purple/10 mb-8">
                      <h3 class="text-white font-semibold mb-2">Over dit examen</h3>
                      <p class="text-white/80 text-sm leading-relaxed">
                        {#if testType === 'dmv'}
                          Test je kennis van de verkeersregels en vaardigheden die nodig zijn voor veilig autorijden. Bereid je goed voor!
                        {:else if testType === 'boat'}
                          Leer de essentiële vaarregels en veiligheidsmaatregelen voor het besturen van een boot op het water.
                        {:else if testType === 'bike'}
                          Test je kennis over motorrijden, specifieke verkeersregels en belangrijke veiligheidsaspecten.
                        {:else if testType === 'truck'}
                          Bereid je voor op het vrachtwagenexamen met vragen over speciale regelgeving en ladingveiligheid.
                        {/if}
                      </p>
                    </div>

                    <!-- Start Button -->
                    <button 
                      class="w-full bg-gradient-to-br from-brand-purple/10 to-brand-purple/5 
                        border border-brand-purple/10 text-white font-medium 
                        rounded-xl px-6 py-4 hover:bg-brand-purple/15
                        transition-all duration-200 group"
                      on:click={startExam}
                    >
                      <div class="flex items-center justify-center gap-2">
                        <span class="text-white/90 group-hover:text-white transition-colors">Start Examen</span>
                        <ArrowRight 
                          class="w-4 h-4 text-brand-purple group-hover:translate-x-0.5 transition-all" 
                        />
                      </div>
                    </button>
                  </div>
                </div>

              {:else if examState === 'exam'}
                <div class="absolute inset-0"
                  in:fly={{ y: 10, duration: 200 }}
                  out:fly={{ y: -10, duration: 200 }}
                >
                  <div class="relative h-64">
                    {#if questions[currentQuestion].image}
                      {#key currentQuestion}
                        <div class="absolute inset-0"
                          in:fly|local={{ x: 100, duration: 200, easing: cubicOut }}
                          out:fly|local={{ x: -100, duration: 200, easing: cubicOut }}
                        >
                          <img 
                            src={questions[currentQuestion].image} 
                            alt="Vraag illustratie"
                            class="w-full h-full object-cover"
                          />
                        </div>
                      {/key}
                    {/if}
                  </div>

                  <div class="px-8 pt-8 pb-7">
                    {#if !showResult}
                      <div class="flex items-center justify-between mb-8">
                        <div>
                          <h1 class="text-lg font-semibold text-white tracking-tight">
                            Rijbewijs Theorie Examen
                          </h1>
                          <p class="text-sm text-brand-cyan font-medium">
                            Selecteer het juiste antwoord
                          </p>
                        </div>
                        <div class="px-3 py-1.5 rounded-lg bg-brand-blue/5 border border-brand-blue/10">
                          <span class="text-sm font-medium text-brand-cyan">
                            {currentQuestion + 1}/{questions.length}
                          </span>
                        </div>
                      </div>

                      <!-- Container voor vragen met vaste hoogte -->
                      <div style="min-height: 240px" class="relative mb-20"> <!-- Veranderd van mb-12 naar mb-20 -->
                        {#key currentQuestion}
                          <div 
                            class="absolute inset-0 w-full"
                            in:fly|local={{ x: 100, duration: 200, easing: cubicOut }}
                            out:fly|local={{ x: -100, duration: 200, easing: cubicOut }}
                          >
                            <div class="mb-6">
                              <h2 class="text-[15px] text-white font-medium leading-relaxed">
                                {questions[currentQuestion].question}
                              </h2>
                            </div>
                          
                            <div class="space-y-2.5">
                              {#each questions[currentQuestion].answers as answer, i}
                                <button 
                                  class="group w-full px-4 py-3.5 text-left rounded-lg text-[15px]
                                    transition-all duration-200 border
                                    {selectedAnswer === i 
                                      ? 'bg-brand-purple/20 text-white border-brand-purple/30' 
                                      : 'bg-brand-blue/5 hover:bg-brand-cyan/10 border-white/[0.06] hover:border-brand-cyan/20'}"
                                  on:click={() => selectedAnswer = i}
                                >
                                  <div class="flex items-center gap-3.5">
                                    <div class="w-[18px] h-[18px] rounded-full flex-shrink-0 border-2 transition-all
                                      {selectedAnswer === i 
                                        ? 'border-brand-coolPurple bg-brand-coolPurple/20' 
                                        : 'border-brand-cyan/30 group-hover:border-brand-cyan'}"
                                    >
                                      {#if selectedAnswer === i}
                                        <div class="w-full h-full rounded-full bg-brand-coolPurple scale-[0.4]"></div>
                                      {/if}
                                    </div>
                                    <span class="text-white/90">{answer}</span>
                                  </div>
                                </button>
                              {/each}
                            </div>
                          </div>
                        {/key}
                      </div>

                      <div class="flex justify-end"> <!-- Verwijderd mt-8 omdat we mb-12 hierboven gebruiken -->
                        <button 
                          class={`px-5 py-2.5 rounded-xl text-sm inline-flex items-center gap-2
                            transition-all duration-200
                            ${selectedAnswer === null 
                              ? 'bg-white/5 text-white/30 cursor-not-allowed' 
                              : 'bg-brand-blue hover:bg-brand-blue/90 text-white'
                            }`}
                          on:click={handleAnswer} 
                          disabled={selectedAnswer === null}
                        >
                          <span>
                            {currentQuestion === questions.length - 1 ? 'Afronden' : 'Volgende'}
                          </span>
                          {#if currentQuestion !== questions.length - 1}
                            <ArrowRight class="w-4 h-4" />
                          {/if}
                        </button>
                      </div>
                    {/if}
                  </div>
                </div>

              {:else}
                <div class="absolute inset-0 flex flex-col items-center justify-center"
                  in:fly={{ y: 10, duration: 200 }}
                  out:fly={{ y: -10, duration: 200 }}
                >
                  <div class="flex flex-col items-center gap-12">
                    <div class="relative w-48 h-48">
                      <svg class="w-full h-full transform -rotate-90" viewBox="0 0 120 120">
                        <circle
                          cx="60"
                          cy="60"
                          r="52"
                          fill="none"
                          stroke="currentColor"
                          stroke-width="8"
                          class="text-brand-purple/10"
                        />
                        <circle
                          cx="60"
                          cy="60"
                          r="52"
                          fill="none"
                          stroke="currentColor"
                          stroke-width="8"
                          stroke-dasharray={326.7}
                          stroke-dashoffset={326.7 - ($progressTween / 100) * 326.7}
                          class="text-brand-purple"
                        />
                      </svg>
                      <div class="absolute inset-0 flex items-center justify-center">
                        <span class="text-5xl font-bold text-white">
                          {Math.round($progressTween)}%
                        </span>
                      </div>
                    </div>

                    <div class="space-y-3 text-center">
                      <h2 class="text-3xl font-semibold text-white">
                        {passed ? 'Gefeliciteerd!' : 'Helaas!'}
                      </h2>
                      <div class="space-y-2">
                        <p class="text-lg text-white/90">
                          {passed 
                            ? 'Je bent geslaagd voor het theorie-examen.' 
                            : 'Je bent helaas niet geslaagd voor het theorie-examen.'}
                        </p>
                        <p class="text-sm text-brand-cyan">
                          Je hebt {score} van de {questions.length} vragen goed beantwoord
                        </p>
                      </div>
                    </div>

                    <button 
                      class="px-8 py-3 rounded-md text-sm font-medium bg-brand-purple text-white hover:bg-brand-purple/90 transition-colors"
                      on:click={async () => {
                        // Alleen uitvoeren als we in FiveM zitten (niet localhost)
                        if (
                          typeof GetParentResourceName === 'function' && 
                          'invokeNative' in window && 
                          window.location.hostname !== "localhost"
                        ) {
                          const resourceName = GetParentResourceName();
                          try {
                            await fetch(`https://${resourceName}/${passed ? 'close' : 'kick'}`, {
                              method: 'POST',
                              headers: { 'Content-Type': 'application/json' },
                              body: JSON.stringify({ passed, type: testType })
                            });
                          } catch (error) {
                            console.error("[NUI] Fetch error:", error);
                          }
                        } else {
                          console.warn("Not in FiveM environment or running on localhost; skipping fetch");
                        }
                        visible = false;
                      }}
                    >
                      Sluiten
                    </button>
                  </div>
                </div>
              {/if}
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
{/if}
