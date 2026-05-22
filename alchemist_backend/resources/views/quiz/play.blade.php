<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Playing Quiz — Alchemist</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300;400;500;600;700&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        :root {
            --bg:       #080d0e;
            --cyan:     #00d4d4;
            --lime:     #b8f400;
            --red:      #ff4646;
            --card:     #0d1c1e;
            --card2:    #101f22;
            --text:     #ffffff;
            --muted:    rgba(255,255,255,0.4);
            --border:   rgba(255,255,255,0.06);
        }

        html, body {
            height: 100%; font-family: 'Space Grotesk', sans-serif;
            background: var(--bg); color: var(--text);
            overflow: hidden;
        }

        .quiz-wrapper {
            display: flex; flex-direction: column; height: 100vh;
            padding: 40px 24px; position: relative;
        }

        .header {
            max-width: 680px; width: 100%; margin: 0 auto 32px;
        }
        .chapter-label {
            font-size: 14px; font-weight: 700; color: var(--cyan);
            text-transform: lowercase; margin-bottom: 12px;
        }
        .progress-bar-wrap {
            height: 12px; background: rgba(255,255,255,0.1); border-radius: 99px;
            overflow: hidden; width: 100%;
        }
        .progress-bar-fill {
            height: 100%; background: var(--cyan); border-radius: 99px;
            transition: width 0.3s ease; width: 0%;
            box-shadow: 0 0 8px var(--cyan);
        }

        /* ── QUESTIONS CONTAINER ── */
        .question-container {
            flex: 1; max-width: 680px; width: 100%; margin: 0 auto;
            display: flex; flex-direction: column; overflow-y: auto;
            padding-bottom: 200px; /* Space for the stacked bottom bar when expanded */
        }
        .question-container::-webkit-scrollbar { display: none; }

        .question-title {
            font-size: 22px; font-weight: 500; text-align: center;
            line-height: 1.4; margin-bottom: 40px; font-family: 'Inter', sans-serif;
        }

        /* ── MULTIPLE CHOICE (TACTILE 3D TEAL TO LIME) ── */
        .options-list {
            display: flex; flex-direction: column; gap: 20px; width: 100%;
        }
        .option-btn {
            background: #084d56; border: 1px solid rgba(255,255,255,0.03);
            border-radius: 16px; padding: 22px 28px;
            display: flex; align-items: center; gap: 24px;
            cursor: pointer; position: relative;
            transform: translateY(0);
            box-shadow: 0 8px 0 #032e34;
            transition: transform 0.1s, box-shadow 0.1s, background 0.1s;
            text-align: left; user-select: none;
        }
        .option-btn:hover {
            background: #0a5761;
        }
        .option-btn.selected {
            background: #b8f400; color: #000;
            box-shadow: 0 2px 0 #7fa600;
            transform: translateY(6px);
        }
        .option-btn.selected .option-label {
            color: #000;
        }
        .option-label {
            font-size: 28px; font-weight: 700; color: #fff;
            font-family: 'Space Grotesk', sans-serif;
            min-width: 32px;
        }
        .option-text {
            font-size: 16px; font-weight: 600; font-family: 'Inter', sans-serif;
        }

        /* ── SENTENCE ARRANGEMENT ── */
        .assembly-box {
            border: 2px dashed rgba(255,255,255,0.15); border-radius: 16px;
            min-height: 120px; padding: 20px; display: flex; flex-wrap: wrap;
            gap: 12px; align-content: flex-start; margin-bottom: 32px;
            background: rgba(0,0,0,0.2);
        }
        .word-pool {
            display: flex; flex-wrap: wrap; gap: 12px; justify-content: center;
        }
        .word-pill {
            background: #084d56; border: 1px solid rgba(255,255,255,0.03);
            border-radius: 10px; padding: 12px 20px; font-size: 14px;
            font-weight: 700; color: #fff; cursor: pointer;
            box-shadow: 0 6px 0 #032e34; transform: translateY(0);
            transition: 0.1s;
        }
        .word-pill:active { transform: translateY(4px); box-shadow: 0 2px 0 #032e34; }
        .word-pill.used { opacity: 0.2; pointer-events: none; }
        
        .word-pill.colored-0 { background: #b8f400; color: #000; box-shadow: 0 6px 0 #7fa600; }
        .word-pill.colored-1 { background: #b073ff; color: #000; box-shadow: 0 6px 0 #7345b2; }
        .word-pill.colored-2 { background: #00d4d4; color: #000; box-shadow: 0 6px 0 #008888; }

        /* ── LAB PRACTICE ── */
        .lab-setup {
            display: flex; justify-content: center; align-items: flex-end;
            gap: 20px; margin-bottom: 40px;
        }
        .beaker-container {
            display: flex; flex-direction: column; align-items: center; gap: 12px;
        }
        .beaker {
            width: 100px; height: 120px; border: 4px solid #fff;
            border-top: none; border-radius: 0 0 16px 16px;
            position: relative; overflow: hidden; background: transparent;
        }
        .beaker-liquid {
            position: absolute; bottom: 0; left: 0; right: 0;
            height: 0%; transition: height 0.5s ease, background 0.3s;
        }
        .beaker-liquid.filled { height: 60%; }
        .beaker-label { font-size: 11px; font-weight: 700; color: var(--muted); text-transform: uppercase; }
        
        .lab-operator { font-size: 40px; color: var(--cyan); font-weight: 300; padding-bottom: 40px; }

        .chemical-pool {
            display: flex; flex-wrap: wrap; gap: 12px; justify-content: center;
            margin-bottom: 24px;
        }
        .chemical-pill {
            padding: 10px 18px; border-radius: 12px; font-size: 13px; font-weight: 700;
            cursor: pointer; text-align: center; border: 1px solid rgba(255,255,255,0.05);
            box-shadow: 0 4px 0 rgba(0,0,0,0.4);
        }
        .chem-acid { background: #ff4646; color: #fff; }
        .chem-base { background: #0072ff; color: #fff; }
        .chem-salt { background: #888; color: #fff; }
        .chem-metal { background: #ff9900; color: #fff; }
        .chem-other { background: #00cc66; color: #fff; }

        .lab-buttons {
            display: flex; justify-content: center; gap: 16px; margin-bottom: 32px;
        }
        .btn-lab {
            padding: 12px 24px; border-radius: 10px; border: none; font-size: 13px;
            font-weight: 700; cursor: pointer; text-transform: uppercase;
        }
        .btn-lab.mix { background: var(--lime); color: #000; }
        .btn-lab.reset { background: #990000; color: #fff; }

        /* ── DYNAMIC MORPHING BOTTOM DRAWER (VERTICAL STACK) ── */
        .bottom-bar {
            position: fixed; bottom: 0; left: 0; right: 0;
            background: transparent; border-top: none;
            padding: 16px 24px; display: flex; flex-direction: column; align-items: center;
            height: 88px; transition: height 0.3s cubic-bezier(0.1, 0.8, 0.3, 1), background 0.3s;
            z-index: 999;
        }
        .bottom-bar.expanded {
            height: 230px;
        }
        .bottom-bar.correct { background: var(--lime); color: #000; }
        .bottom-bar.incorrect { background: var(--red); color: #fff; }

        .drawer-status {
            display: none; align-items: center; gap: 12px; font-size: 18px; font-weight: 700;
            text-transform: uppercase; margin-bottom: 16px; margin-top: 0px;
        }
        .bottom-bar.expanded .drawer-status { display: flex; }
        .drawer-status svg { width: 28px; height: 28px; fill: currentColor; }

        .drawer-buttons {
            display: flex; flex-direction: column; gap: 12px; width: 100%; max-width: 440px;
        }
        .btn-drawer {
            width: 100%; padding: 18px 0; border-radius: 12px; border: none;
            font-size: 14px; font-weight: 700; cursor: pointer; text-transform: uppercase;
            font-family: inherit; letter-spacing: 0.05em; text-align: center;
        }
        
        .btn-drawer.explanation {
            display: none; background: #00d4d4; color: #000;
            box-shadow: 0 6px 0 #008888;
            transition: transform 0.1s, box-shadow 0.1s;
        }
        .btn-drawer.explanation:active {
            transform: translateY(4px); box-shadow: 0 2px 0 #008888;
        }
        .bottom-bar.expanded .btn-drawer.explanation {
            display: block;
        }
        
        .btn-drawer.continue {
            background: var(--cyan); color: #000;
            box-shadow: 0 6px 0 #008888;
            transition: transform 0.1s, box-shadow 0.1s, background 0.1s;
        }
        .btn-drawer.continue:disabled {
            background: #1b2e31; color: var(--muted); box-shadow: 0 6px 0 #0c181a;
            cursor: not-allowed;
        }
        .btn-drawer.continue:active:not(:disabled) {
            transform: translateY(4px); box-shadow: 0 2px 0 #008888;
        }

        /* Styling inside active green / red drawer */
        .bottom-bar.correct .btn-drawer.continue {
            background: #9bd600; color: #000; box-shadow: 0 6px 0 #709900;
        }
        .bottom-bar.correct .btn-drawer.continue:active {
            transform: translateY(4px); box-shadow: 0 2px 0 #709900;
        }
        
        .bottom-bar.incorrect .btn-drawer.continue {
            background: #ffffff; color: #000; box-shadow: 0 6px 0 #cccccc;
        }
        .bottom-bar.incorrect .btn-drawer.continue:active {
            transform: translateY(4px); box-shadow: 0 2px 0 #cccccc;
        }

        /* ── EXPLANATION SCREEN ── */
        .explanation-screen {
            position: fixed; top: 0; left: 0; right: 0; bottom: 0;
            background: var(--lime); color: #000; z-index: 10000;
            padding: 60px 40px; display: flex; flex-direction: column;
            opacity: 0; pointer-events: none; transition: opacity 0.2s;
            overflow-y: auto;
        }
        .explanation-screen.open { opacity: 1; pointer-events: auto; }
        .exp-title { font-size: 32px; font-weight: 700; margin-bottom: 32px; }
        .exp-text { font-size: 18px; line-height: 1.7; font-family: 'Inter', sans-serif; font-weight: 500; margin-bottom: 40px; }
        .btn-exp-back {
            background: #000; color: #fff; padding: 18px 40px; border-radius: 12px;
            font-size: 14px; font-weight: 700; text-transform: uppercase; border: none;
            cursor: pointer; align-self: flex-start;
        }

    </style>
</head>
<body>
<div class="quiz-wrapper">

    <!-- HEADER -->
    <header class="header">
        <div class="chapter-label" id="chapter-label">chapter {{ $level->chapter->order_index ?? 1 }}: {{ $level->chapter->title ?? 'Chemistry' }}</div>
        <div class="progress-bar-wrap">
            <div class="progress-bar-fill" id="progress-bar-fill"></div>
        </div>
    </header>

    <!-- QUESTION PLACEHOLDER -->
    <main class="question-container" id="question-container">
        <!-- Rendered dynamically by Javascript -->
    </main>

    <!-- DYNAMIC MORPHING BOTTOM BAR (VERTICAL STACK) -->
    <div class="bottom-bar" id="bottom-bar">
        <div class="drawer-status" id="drawer-status">
            <!-- Injected dynamically by JS -->
        </div>
        <div class="drawer-buttons">
            <button class="btn-drawer explanation" id="btn-explanation" onclick="showExplanation()">Explanation</button>
            <button class="btn-drawer continue" id="btn-continue" disabled onclick="handleContinueClick()">Check</button>
        </div>
    </div>

    <!-- EXPLANATION FULLSCREEN -->
    <div class="explanation-screen" id="explanation-screen">
        <div class="exp-title">Pembahasan</div>
        <div class="exp-text" id="exp-text">
            Lorem Ipsum is simply dummy text of the printing and typesetting industry.
        </div>
        <button class="btn-exp-back" onclick="closeExplanation()">Back to Quiz</button>
    </div>

</div>

<script>
    const questions = @json($level->questions);
    let currentQuestionIndex = 0;
    
    let wrongAnswersCount = 0;
    let startTime = Date.now();
    
    let labSelectedA = null;
    let labSelectedB = null;
    let labReacted = false;

    let sentenceAnswerWords = [];
    
    let selectedOption = null;
    let answered = false;

    window.onload = function() {
        if (questions.length === 0) {
            alert("No questions found in this level!");
            window.location.href = "{{ route('quiz') }}";
            return;
        }
        renderQuestion();
    };

    function updateProgressBar() {
        const fill = document.getElementById('progress-bar-fill');
        const percentage = ((currentQuestionIndex) / questions.length) * 100;
        fill.style.width = percentage + '%';
    }

    function renderQuestion() {
        updateProgressBar();
        resetBottomBar();
        
        answered = false;
        selectedOption = null;

        const question = questions[currentQuestionIndex];
        const container = document.getElementById('question-container');
        container.innerHTML = ''; 

        // Title
        const titleEl = document.createElement('h2');
        titleEl.className = 'question-title';
        titleEl.innerText = question.question_text;
        container.appendChild(titleEl);

        if (question.type === 'MULTIPLE_CHOICE') {
            renderMultipleChoice(question, container);
        } else if (question.type === 'SENTENCE_ARRANGEMENT') {
            renderSentenceArrangement(question, container);
        } else if (question.type === 'LAB_PRACTICE') {
            renderLabPractice(question, container);
        }
    }

    // 1. MULTIPLE CHOICE RENDER
    function renderMultipleChoice(question, container) {
        const optionsList = document.createElement('div');
        optionsList.className = 'options-list';

        const options = question.multiple_choice_options || [];
        
        options.forEach(option => {
            const btn = document.createElement('div');
            btn.className = 'option-btn';
            btn.innerHTML = `
                <div class="option-label">${option.option_label}</div>
                <div class="option-text">${option.option_text}</div>
            `;
            btn.onclick = () => {
                if (answered) return;
                document.querySelectorAll('.option-btn').forEach(b => b.classList.remove('selected'));
                btn.classList.add('selected');
                selectedOption = option;
                document.getElementById('btn-continue').disabled = false;
            };
            optionsList.appendChild(btn);
        });

        container.appendChild(optionsList);
    }

    // 2. SENTENCE ARRANGEMENT RENDER
    function renderSentenceArrangement(question, container) {
        sentenceAnswerWords = [];
        
        const assembly = document.createElement('div');
        assembly.className = 'assembly-box';
        assembly.id = 'assembly-box';
        container.appendChild(assembly);

        const pool = document.createElement('div');
        pool.className = 'word-pool';
        
        const dbWords = question.sentence_arrangement_words || [];
        
        dbWords.forEach((item, index) => {
            const pill = document.createElement('div');
            pill.className = `word-pill`;
            pill.innerText = item.word_text || item.word;
            pill.id = `pool-word-${index}`;
            pill.onclick = () => {
                if (answered) return;
                addWordToAssembly(item.word_text || item.word, index);
            };
            pool.appendChild(pill);
        });

        container.appendChild(pool);
    }

    function addWordToAssembly(word, index) {
        const pill = document.getElementById(`pool-word-${index}`);
        pill.classList.add('used');

        const assembly = document.getElementById('assembly-box');
        
        const ansPill = document.createElement('div');
        ansPill.className = `word-pill colored-0`;
        ansPill.innerText = word;
        ansPill.onclick = () => {
            if (answered) return;
            ansPill.remove();
            pill.classList.remove('used');
            sentenceAnswerWords = sentenceAnswerWords.filter(w => w.index !== index);
            
            const totalWords = questions[currentQuestionIndex].sentence_arrangement_words.length;
            if (sentenceAnswerWords.length < totalWords) {
                document.getElementById('btn-continue').disabled = true;
            }
        };
        
        assembly.appendChild(ansPill);
        sentenceAnswerWords.push({ word, index });

        const totalWords = questions[currentQuestionIndex].sentence_arrangement_words.length;
        if (sentenceAnswerWords.length === totalWords) {
            document.getElementById('btn-continue').disabled = false;
        }
    }

    // 3. LAB PRACTICE RENDER
    function renderLabPractice(question, container) {
        labSelectedA = null;
        labSelectedB = null;
        labReacted = false;

        const config = question.lab_practice_config || {};

        const setup = document.createElement('div');
        setup.className = 'lab-setup';
        setup.innerHTML = `
            <div class="beaker-container">
                <div class="beaker">
                    <div class="beaker-liquid" id="liquid-a"></div>
                </div>
                <div class="beaker-label" id="label-a">Beaker A</div>
            </div>
            <div class="lab-operator">+</div>
            <div class="beaker-container">
                <div class="beaker">
                    <div class="beaker-liquid" id="liquid-b"></div>
                </div>
                <div class="beaker-label" id="label-b">Beaker B</div>
            </div>
            <div class="lab-operator">=</div>
            <div class="beaker-container">
                <div class="beaker">
                    <div class="beaker-liquid" id="liquid-c"></div>
                </div>
                <div class="beaker-label" id="label-c">Result</div>
            </div>
        `;
        container.appendChild(setup);

        const chemPool = document.createElement('div');
        chemPool.className = 'chemical-pool';
        
        const chemicals = [
            { name: config.beaker_a_chemical || 'HCl', type: 'chem-acid', label: 'Acid' },
            { name: config.beaker_b_chemical || 'NaOH', type: 'chem-base', label: 'Base' },
            { name: 'AgNO3', type: 'chem-salt', label: 'Salt' },
            { name: 'NaCl', type: 'chem-salt', label: 'Salt' },
            { name: 'Zn', type: 'chem-metal', label: 'Metal' },
            { name: 'H2SO4', type: 'chem-acid', label: 'Acid' },
            { name: 'CuSO4', type: 'chem-other', label: 'Salt' }
        ];

        chemicals.forEach(chem => {
            const pill = document.createElement('div');
            pill.className = `chemical-pill ${chem.type}`;
            pill.innerHTML = `<div>${chem.name}</div><div style="font-size:9px; opacity:0.7;">${chem.label}</div>`;
            pill.onclick = () => {
                if (labReacted) return;
                
                if (!labSelectedA) {
                    labSelectedA = chem.name;
                    document.getElementById('label-a').innerText = `Beaker A (${chem.name})`;
                    const liquid = document.getElementById('liquid-a');
                    liquid.classList.add('filled');
                    liquid.style.background = getChemicalColor(chem.name);
                } else if (!labSelectedB) {
                    labSelectedB = chem.name;
                    document.getElementById('label-b').innerText = `Beaker B (${chem.name})`;
                    const liquid = document.getElementById('liquid-b');
                    liquid.classList.add('filled');
                    liquid.style.background = getChemicalColor(chem.name);
                }
            };
            chemPool.appendChild(pill);
        });
        container.appendChild(chemPool);

        const btnBox = document.createElement('div');
        btnBox.className = 'lab-buttons';
        btnBox.innerHTML = `
            <button class="btn-lab mix" onclick="reactLab()">Mix & React</button>
            <button class="btn-lab reset" onclick="resetLab()">Reset</button>
        `;
        container.appendChild(btnBox);

        const optionsWrapper = document.createElement('div');
        optionsWrapper.id = 'lab-options-wrapper';
        optionsWrapper.style.display = 'none';
        container.appendChild(optionsWrapper);
    }

    function getChemicalColor(chem) {
        const c = chem.toUpperCase();
        if (c.includes('HCL') || c.includes('HCI')) return '#8c3a3a';
        if (c.includes('H2SO4')) return '#c26210';
        if (c.includes('NAOH')) return '#0072ff';
        if (c.includes('CUSO4')) return '#00b050';
        if (c.includes('AGNO3')) return '#888';
        return '#00b0b0';
    }

    function resetLab() {
        labSelectedA = null;
        labSelectedB = null;
        labReacted = false;

        document.getElementById('label-a').innerText = 'Beaker A';
        document.getElementById('label-b').innerText = 'Beaker B';
        document.getElementById('label-c').innerText = 'Result';

        document.getElementById('liquid-a').classList.remove('filled');
        document.getElementById('liquid-b').classList.remove('filled');
        document.getElementById('liquid-c').classList.remove('filled');

        document.getElementById('lab-options-wrapper').style.display = 'none';
        document.getElementById('lab-options-wrapper').innerHTML = '';
        
        document.getElementById('btn-continue').disabled = true;
    }

    function reactLab() {
        if (!labSelectedA || !labSelectedB) {
            alert('Please select chemicals for Beaker A and Beaker B first!');
            return;
        }

        labReacted = true;
        const config = questions[currentQuestionIndex].lab_practice_config || {};

        // Verify if the selection matches expected chemicals (order doesn't matter)
        const expectedA = config.beaker_a_chemical || 'HCl';
        const expectedB = config.beaker_b_chemical || 'NaOH';

        const isChemicalsCorrect = (
            (labSelectedA.toUpperCase() === expectedA.toUpperCase() && labSelectedB.toUpperCase() === expectedB.toUpperCase()) ||
            (labSelectedA.toUpperCase() === expectedB.toUpperCase() && labSelectedB.toUpperCase() === expectedA.toUpperCase())
        );

        if (!isChemicalsCorrect) {
            // Failed reaction!
            const liquidC = document.getElementById('liquid-c');
            liquidC.style.background = '#3a3a3a'; // grey/dirty color
            liquidC.classList.add('filled');
            document.getElementById('label-c').innerText = 'Result (Failed Reaction)';

            // Mark as answered and show incorrect immediately
            answered = true;
            document.getElementById('btn-continue').disabled = false;
            showExpandedBar(false);
            return;
        }

        // Correct reaction! Proceed to multiple choice selection
        const liquidC = document.getElementById('liquid-c');
        liquidC.style.background = '#00b050'; // Success green/cyan
        liquidC.classList.add('filled');
        
        document.getElementById('label-c').innerText = `Result (${config.expected_visual_result || 'Solved'})`;

        setTimeout(() => {
            const optionsWrapper = document.getElementById('lab-options-wrapper');
            optionsWrapper.innerHTML = '';
            optionsWrapper.style.display = 'block';

            const optionsList = document.createElement('div');
            optionsList.className = 'options-list';

            const options = questions[currentQuestionIndex].multiple_choice_options || [];
            
            options.forEach(option => {
                const btn = document.createElement('div');
                btn.className = 'option-btn';
                btn.innerHTML = `
                    <div class="option-label">${option.option_label}</div>
                    <div class="option-text">${option.option_text}</div>
                `;
                btn.onclick = () => {
                    if (answered) return;
                    document.querySelectorAll('#lab-options-wrapper .option-btn').forEach(b => b.classList.remove('selected'));
                    btn.classList.add('selected');
                    selectedOption = option;
                    document.getElementById('btn-continue').disabled = false;
                };
                optionsList.appendChild(btn);
            });
            
            optionsWrapper.appendChild(optionsList);
            optionsWrapper.scrollIntoView({ behavior: 'smooth' });
        }, 500);
    }

    // ── CLICK CONTINUE BUTTON (SINGLE CONTINUOUS BUTTON) ──
    function handleContinueClick() {
        if (!answered) {
            answered = true;
            const question = questions[currentQuestionIndex];
            
            let isCorrect = false;
            if (question.type === 'MULTIPLE_CHOICE' || question.type === 'LAB_PRACTICE') {
                isCorrect = selectedOption.is_correct == 1;
            } else if (question.type === 'SENTENCE_ARRANGEMENT') {
                const dbWords = question.sentence_arrangement_words;
                isCorrect = true;
                sentenceAnswerWords.forEach((item, idx) => {
                    const dbItem = dbWords[item.index];
                    if (dbItem.correct_order_index != idx) {
                        isCorrect = false;
                    }
                });
            }
            
            showExpandedBar(isCorrect);
        } else {
            nextQuestion();
        }
    }

    function showExpandedBar(isCorrect) {
        const bottomBar = document.getElementById('bottom-bar');
        const status = document.getElementById('drawer-status');
        
        bottomBar.classList.remove('correct', 'incorrect');
        bottomBar.classList.add('expanded');
        
        // Dynamically change text to CONTINUE
        document.getElementById('btn-continue').innerText = 'Continue';

        if (isCorrect) {
            bottomBar.classList.add('correct');
            status.innerHTML = `
                <svg viewBox="0 0 24 24" style="fill: #000;"><path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/></svg>
                <span>Correct Answer</span>
            `;
        } else {
            wrongAnswersCount++;
            bottomBar.classList.add('incorrect');
            status.innerHTML = `
                <svg viewBox="0 0 24 24" style="fill: #fff;"><path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/></svg>
                <span>Incorrect Answer</span>
            `;
        }
    }

    function resetBottomBar() {
        const bottomBar = document.getElementById('bottom-bar');
        bottomBar.className = 'bottom-bar'; // reset classes
        document.getElementById('btn-continue').disabled = true;
        // Dynamically reset text to CHECK
        document.getElementById('btn-continue').innerText = 'Check';
    }

    // ── EXPLANATION PANEL ──
    function showExplanation() {
        const currentQ = questions[currentQuestionIndex];
        document.getElementById('exp-text').innerText = currentQ.explanation || 'Pembahasan tidak tersedia.';
        document.getElementById('explanation-screen').classList.add('open');
    }

    function closeExplanation() {
        document.getElementById('explanation-screen').classList.remove('open');
    }

    // ── NEXT QUESTION OR COMPLETE ──
    function nextQuestion() {
        currentQuestionIndex++;
        if (currentQuestionIndex < questions.length) {
            renderQuestion();
        } else {
            completeQuiz();
        }
    }

    function completeQuiz() {
        const totalSeconds = Math.round((Date.now() - startTime) / 1000);
        const score = Math.max(0, 100 - (wrongAnswersCount * 20));

        let totalXpReward = 0;
        questions.forEach(q => {
            totalXpReward += q.xp_reward;
        });

        fetch(`/quiz/play/{{ $level->id }}/complete`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-TOKEN': '{{ csrf_token() }}'
            },
            body: JSON.stringify({
                score: score,
                completion_time_seconds: totalSeconds,
                wrong_answers_count: wrongAnswersCount,
                xp_earned: totalXpReward
            })
        })
        .then(res => res.json())
        .then(data => {
            if (data.success) {
                if (data.xp_earned > 0) {
                    alert(`Level completed! You earned ${data.xp_earned} XP!`);
                } else {
                    alert(`Level completed! (No XP earned: you already completed this level before).`);
                }
                window.location.href = data.redirect;
            }
        })
        .catch(err => {
            console.error(err);
            window.location.href = "{{ route('quiz') }}";
        });
    }
</script>
</body>
</html>
