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

  // Function to get correct image path
  function getImagePath(imageName: string) {
    return `/${imageName}`; // Dit pakt de afbeelding uit de static folder
  }

  // Add question sets for different categories
  const questionSets = {
    dmv: [
      {
        question: "Je rijdt in de regen op de snelweg. Wat moet je doen?",
        image: getImagePath("auto1.png"),
        answers: [
          "Snelheid verhogen om snel thuis te zijn",
          "Afstand verkleinen tot voorligger",
          "Snelheid verminderen en meer afstand houden",
          "Alarmlichten aanzetten"
        ],
        correct: 2
      },
      {
          question: "Wanneer moet je je richtingaanwijzer aanzetten voor deze afslag?",
          image: getImagePath("auto2.png"),
          answers: [
              "Direct voor het afslaan",
              "Ongeveer 100 meter voor de afslag",
              "Na het afslaan",
              "Richtingaanwijzer is niet nodig"
          ],
          correct: 1
      },
      {
          question: "Mag je hier je auto parkeren?",
          image: getImagePath("auto3.png"),
          answers: [
              "Ja, je mag hier parkeren",
              "Ja, alleen om te laden en lossen",
              "Ja, als je snel weer weg bent",
              "Nee je mag hier niet parkeren"
          ],
          correct: 3
      },
      {
        question: "Wat betekent de dubbele doorgetrokken gele streep in het midden van de weg?",
        image: getImagePath("auto4.png"),
        answers: [
          "Je mag hier niet inhalen",
          "Je mag hier wel inhalen",
          "Je mag hier parkeren",
          "Je mag hier stoppen"
        ],
        correct: 0
      },
      {
        question: "Je nadert deze kruising. Wie heeft er voorrang?",
        image: getImagePath("auto5.png"),
        answers: [
          "Jij hebt voorrang",
          "De auto van rechts",
          "De snelste heeft voorrang",
          "Grootste voertuig heeft voorrang"
        ],
        correct: 1
      },
      {
        question: "Welke rijstijl is correct in deze weersomstandigheden?",
        image: getImagePath("auto6.png"),
        answers: [
          "Mistlicht voor én achter aan",
          "Alleen mistlicht achter aan",
          "Groot licht aan voor beter zicht",
          "Alleen dimlicht is voldoende"
        ],
        correct: 1
      },
      {
          question: "In welke volgorde moet je de spiegels controleren voor het wisselen van rijstrook?",
          image: getImagePath("auto7.png"),
          answers: [
              "Alleen linkerspiegel",
              "Binnenspiegel, buitenspiegels, schoudercheck",
              "Schoudercheck is voldoende",
              "Alleen binnenspiegel en rechterspiegel"
          ],
          correct: 1
      },
      {
        question: "Wat is de juiste reactie in deze situatie?",
        image: getImagePath("auto8.png"),
        answers: [
          "Direct vol op de rem",
          "Rustig vaart minderen",
          "Uitwijken naar rechts",
          "Claxonneren en doorrijden"
        ],
        correct: 0
      },
      {
          question: "Wanneer moet je je groot licht dimmen?",
          image: getImagePath("auto9.png"),
          answers: [
              "Alleen bij tegemoetkomend verkeer",
              "Bij tegemoetkomend verkeer en achter andere voertuigen",
              "Alleen als andere bestuurders seinen",
              "Alleen binnen de bebouwde kom"
          ],
          correct: 1
      },
      {
        question: "Wat moet je doen als je een politieauto met sirene en zwaailicht achter je ziet?",
        image: getImagePath("auto10.png"),
        answers: [
          "Direct hard remmen",
          "Rustig naar rechts gaan en ruimte maken",
          "Doorrijden op dezelfde snelheid",
          "Snelheid verhogen om weg te komen"
        ],
        correct: 1
      }
    ],
    boat: [
      {
        question: "Welke kant moet je uitwijken als je een andere boot tegenkomt?",
        image: getImagePath("boot1.png"), 
        answers: [
          "Naar stuurboord (rechts)",
          "Naar bakboord (links)",
          "Maakt niet uit",
          "Rechtdoor varen"
        ],
        correct: 0
      },
      {
        question: "Wat betekent deze boei?",
        image: getImagePath("boot2.png"),
        answers: [
          "Veilige wateren",
          "Gevaarlijke rotsen",
          "Verboden te varen",
          "Aanlegplaats"
        ],
        correct: 2
      },
      {
        question: "Hoe controleer je het weer voor vertrek?",
        image: getImagePath("boot3.png"),
        answers: [
          "Alleen windrichting checken",
          "Complete weersverwachting bekijken",
          "Naar buiten kijken is voldoende",
          "Alleen temperatuur checken"
        ],
        correct: 1
      },
      {
          question: "Wat moet je doen bij het varen in mist?",
          image: getImagePath("boot4.png"),
          answers: [
              "Normaal doorvaren",
              "Geluidssignalen geven en snelheid minderen",
              "Anker uitgooien en wachten",
              "Alleen op radar varen"
          ],
          correct: 1
      },
      {
        question: "Wat is de maximumsnelheid in de haven?",
        image: getImagePath("boot5.png"),
        answers: [
          "5 km/u",
          "10 km/u",
          "15 km/u",
          "20 km/u"
        ],
        correct: 0
      },
      {
        question: "Welke veiligheidsuitrusting is verplicht aan boord?",
        image: getImagePath("boot6.png"),
        answers: [
          "Alleen reddingsvesten",
          "Compleet veiligheidspakket",
          "Alleen brandblusser",
          "Niets verplicht"
        ],
        correct: 1
      },
      {
        question: "Hoe reageer je op hoge golven?",
        image: getImagePath("boot7.png"),
        answers: [
          "Golven recht benaderen",
          "Parallel aan de golven varen",
          "Vol gas erdoorheen",
          "Motor uitzetten"
        ],
        correct: 0
      },
      {
        question: "Wat is het maximaal toegestane alcoholpromillage tijdens het varen?",
        image: getImagePath("boot8.png"),
        answers: [
          "0.8 promille",
          "0.5 promille",
          "0.2 promille",
          "1.0 promille"
        ],
        correct: 1
      },
      {
          question: "Wanneer ben je verplicht om een vaarbewijs te hebben?",
          image: getImagePath("boot9.png"),
          answers: [
              "Alleen bij boten langer dan 20 meter",
              "Bij boten sneller dan 20 km/u of langer dan 15 meter",
              "Alleen bij speedboten",
              "Bij alle boten, ongeacht grootte"
          ],
          correct: 1
      },
      {
        question: "Hoe moet je aanmeren in de haven?",
        image: getImagePath("boot10.png"),
        answers: [
          "Zo snel mogelijk",
          "Langzaam en gecontroleerd",
          "Vol gas en dan remmen",
          "Maakt niet uit hoe"
        ],
        correct: 1
      }
    ],
    bike: [
      {
        question: "Wat is de juiste beschermende kleding voor op de motor?",
        image: getImagePath("motor1.png"),
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
        image: getImagePath("motor2.png"),
        answers: [
          "Vol gas door de bocht",
          "Remmen in de bocht",
          "Voor de bocht remmen, tijdens gas bijgeven",
          "Leunen tegen de bocht in"
        ],
        correct: 2
      },
      {
          question: "Welke papieren moet je bij je hebben als je op een motor rijdt?",
          image: getImagePath("motor3.png"), // Fixed: Image -> image
          answers: [
              "Alleen rijbewijs",
              "Rijbewijs en kentekenbewijs",
              "Rijbewijs, kentekenbewijs en verzekeringsbewijs",
              "Alleen kentekenbewijs"
          ],
          correct: 2
      },
      {
        question: "Hoe controleer je de ketting van je motor?",
        image: getImagePath("motor4.png"),
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
        image: getImagePath("motor5.png"),
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
        image: getImagePath("motor6.png"),
        answers: [
          "Rustig rijden en geen abrupte bewegingen",
          "Snel doorrijden",
          "Hard remmen waar nodig",
          "Schuin door bochten"
        ],
        correct: 0
      },
      {
          question: "Welke factoren beïnvloeden de remweg van een motor?",
          image: getImagePath("motor7.png"),
          answers: [
              "Alleen de snelheid",
              "Alleen het wegdek",
              "Snelheid, wegdek en bandenprofiel",
              "Alleen het weer"
          ],
          correct: 2
      },
      {
        question: "Hoe parkeer je een motor op een helling?",
        image: getImagePath("motor8.png"),
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
        image: getImagePath("motor9.png"),
        answers: [
          "Zo snel mogelijk inhalen",
          "Dode hoek checken en veilige afstand",
          "Dicht op voorligger blijven",
          "Claxonneren bij inhalen"
        ],
        correct: 1
      },
      {
          question: "Hoeveel seconden volgafstand moet je minimaal aanhouden op een droge weg?",
          image: getImagePath("motor10.png"),
          answers: [
              "1 seconde",
              "2 seconden",
              "3 seconden",
              "4 seconden"
          ],
          correct: 1
      }
    ],
    truck: [
      {
        question: "Wat is de maximale hoogte voor een vrachtwagen?",
        image: getImagePath("vrachtwagen1.png"),
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
        image: getImagePath("vrachtwagen2.png"),
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
        image: getImagePath("vrachtwagen3.png"),
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
        image: getImagePath("vrachtwagen4.png"),
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
        image: getImagePath("vrachtwagen5.png"),
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
        image: getImagePath("vrachtwagen6.png"),
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
        image: getImagePath("vrachtwagen7.png"),
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
        image: getImagePath("vrachtwagen8.png"),
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
        image: getImagePath("vrachtwagen9.png"),
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
        image: getImagePath("vrachtwagen10.png"),
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
    // Basisresolutie is 1080p (1920x1080)

    const baseWidth = 1920;
    const baseHeight = 1080;

    // Bereken scaling factor op basis van schermgrootte
    const widthScale = window.innerWidth / baseWidth;
    const heightScale = window.innerHeight / baseHeight;

    // Gebruik de kleinste scale factor om aspect ratio te behouden
    scaleFactor = Math.min(widthScale, heightScale);

    // Begrens de scaling tussen 0.4 (40%) en 1.8 (180%)
    scaleFactor = Math.max(0.4, Math.min(1.8, scaleFactor));
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
  <div class="fixed inset-0 z-40 overflow-hidden">
    <div class="absolute inset-0 flex items-center justify-center"
      in:scale={{ duration: 200, start: 0.97 }}
      out:scale={{ duration: 150, start: 1 }}
    >
      <!-- Vaste container met absolute positionering -->
      <div class="absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2">
        <!-- Container met vaste afmetingen -->
        <div class="w-[780px] mx-auto" style="transform: scale({scaleFactor});">
          <div class="bg-brand-black rounded-xl overflow-hidden">
            <div class="h-[900px] relative"> <!-- Verhoogd van 740px naar 900px -->
              {#if examState === 'intro'}
                <!-- Verhoogd padding van px-8 naar px-12 -->
                <div class="absolute inset-0 flex flex-col items-center justify-center px-12"
                  in:fly={{ y: 10, duration: 200, delay: 50 }}
                  out:fly={{ y: -10, duration: 200 }}
                >
                  <div class="w-full max-w-3xl"> <!-- Verhoogd van max-w-2xl naar max-w-3xl -->
                    <!-- Header Section -->
                    <div class="text-center mb-12"> <!-- Verhoogd margin van mb-8 naar mb-12 -->
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

                    <!-- Info Cards Grid - Maak kaarten groter -->
                    <div class="grid grid-cols-2 gap-6 mb-12"> <!-- Verhoogd gap-4 naar gap-6 en mb-8 naar mb-12 -->
                      <div class="bg-gradient-to-br from-brand-purple/10 to-brand-purple/5 rounded-xl p-8 border border-brand-purple/10"> <!-- Verhoogd padding van p-6 naar p-8 -->
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
                      <div class="bg-gradient-to-br from-brand-purple/10 to-brand-purple/5 rounded-xl p-8 border border-brand-purple/10">
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

                    <!-- Description Card - Maak beschrijving groter -->
                    <div class="bg-gradient-to-br from-brand-purple/10 to-brand-purple/5 rounded-xl p-8 border border-brand-purple/10 mb-12">
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

                    <!-- Start Button - Maak knop groter -->
                    <button 
                      class="w-full bg-gradient-to-br from-brand-purple/10 to-brand-purple/5 
                        border border-brand-purple/10 text-white font-medium 
                        rounded-xl px-8 py-5 hover:bg-brand-purple/15
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
                  <!-- Verhoog de afbeeldingshoogte naar h-96 (384px) -->
                  <div class="relative h-96">
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

              {:else if examState === 'result'}
                <div class="absolute inset-0 flex flex-col items-center justify-center"
                  in:fly={{ y: 10, duration: 200 }}
                  out:fly={{ y: -10, duration: 200 }}
                >
                  <div class="flex flex-col items-center gap-16"> <!-- Verhoogd gap van 12 naar 16 -->
                    <div class="relative w-56 h-56"> <!-- Verhoogd van w-48 h-48 naar w-56 h-56 -->
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

                    <div class="space-y-4 text-center"> <!-- Verhoogd gap van space-y-3 naar space-y-4 -->
                      <h2 class="text-4xl font-semibold text-white"> <!-- Verhoogd van text-3xl naar text-4xl -->
                        {passed ? 'Gefeliciteerd!' : 'Helaas!'}
                      </h2>
                      <div class="space-y-3"> <!-- Verhoogd van space-y-2 naar space-y-3 -->
                        <p class="text-xl text-white/90"> <!-- Verhoogd van text-lg naar text-xl -->
                          {passed 
                            ? 'Je bent geslaagd voor het theorie-examen.' 
                            : 'Je bent helaas niet geslaagd voor het theorie-examen.'}
                        </p>
                        <p class="text-base text-brand-cyan"> <!-- Verhoogd van text-sm naar text-base -->
                          Je hebt {score} van de {questions.length} vragen goed beantwoord
                        </p>
                      </div>
                    </div>

                    <button 
                      class="px-12 py-5 rounded-xl text-base font-medium bg-brand-purple text-white"
                      on:click={async () => {
                        const closeUI = async () => {
                          if (
                            typeof GetParentResourceName === 'function' && 
                            'invokeNative' in window
                          ) {
                            const resourceName = GetParentResourceName();
                            await fetch(`https://${resourceName}/${passed ? 'close' : 'kick'}`, {
                              method: 'POST',
                              headers: { 'Content-Type': 'application/json' },
                              body: JSON.stringify({ passed, type: testType })
                            });
                          }
                        };
                    
                        // Eerst de NUI callback aanroepen
                        await closeUI();
                        // Dan pas de UI verbergen
                        visible = false;
                      }}
                    >
                      <div class="flex items-center justify-center gap-3">
                        <span class="tracking-wide">Sluiten</span>
                        <ArrowRight class="w-5 h-5 group-hover:translate-x-0.5 transition-transform" />
                      </div>
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
