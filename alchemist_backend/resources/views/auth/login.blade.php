<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Log In - Alchemist</title>
    <meta name="description" content="Log in to your Alchemist account and continue mastering the elements.">

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300;400;500;600;700&family=Silkscreen&display=swap" rel="stylesheet">

    <style>
        *, *::before, *::after {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        :root {
            --bg:          #0a0e0f;
            --card-bg:     #0f1a1a;
            --card-border: rgba(0, 200, 170, 0.12);
            --input-bg:    #152020;
            --input-border: rgba(255,255,255,0.07);
            --cyan:        #00d9d9;
            --cyan-2:      #00ffcc;
            --white:       #ffffff;
            --muted:       rgba(255,255,255,0.45);
            --label:       rgba(255,255,255,0.55);
        }

        html, body {
            height: 100%;
            font-family: 'Space Grotesk', sans-serif;
            color: var(--white);
            overflow-x: hidden;
        }

        /* ── BACKGROUND ── */
        body {
            min-height: 100vh;
            background-color: var(--bg);
            background-image: url('/images/background.png');
            background-size: cover;
            background-position: center center;
            background-repeat: no-repeat;
            position: relative;
        }

        body::before {
            content: '';
            position: fixed;
            inset: 0;
            background: rgba(5, 10, 10, 0.72);
            pointer-events: none;
            z-index: 0;
        }

        /* ── PAGE LAYOUT ── */
        .page {
            position: relative;
            z-index: 1;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: flex-start;
            padding: 48px 20px 60px;
        }

        /* ── LOGO ── */
        .site-logo {
            font-family: 'Silkscreen', cursive;
            font-size: 1.1rem;
            font-weight: 400;
            letter-spacing: 0.12em;
            color: var(--white);
            text-decoration: none;
            margin-bottom: 32px;
            display: inline-block;
            text-shadow: 0 0 12px rgba(0, 217, 217, 0.25);
            transition: color 0.2s;
        }

        .site-logo:hover {
            color: var(--cyan);
        }

        /* ── TITLE ── */
        .page-title {
            font-size: 2rem;
            font-weight: 700;
            text-align: center;
            margin-bottom: 24px;
            letter-spacing: -0.01em;
        }

        .page-title span {
            color: var(--cyan);
        }

        /* ── SOCIAL GROUP ── */
        .social-group {
            width: 100%;
            max-width: 400px;
            display: flex;
            flex-direction: column;
            align-items: center;
            margin-bottom: 40px;
        }

        /* ── SOCIAL BUTTONS ── */
        .social-btn {
            width: 100%;
            max-width: 400px;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 12px;
            padding: 14px 24px;
            border-radius: 999px;
            border: none;
            font-size: 0.8125rem;
            font-weight: 700;
            letter-spacing: 0.08em;
            text-transform: uppercase;
            cursor: pointer;
            transition: opacity 0.2s, transform 0.2s;
            text-decoration: none;
        }

        .social-btn:hover {
            opacity: 0.9;
            transform: translateY(-1px);
        }

        .btn-facebook {
            background: #1877F2;
            color: #fff;
            margin-bottom: 12px;
        }

        .btn-google {
            background: #fff;
            color: #111;
        }

        /* ── MANUAL LINK ── */
        .manual-link {
            font-size: 0.75rem;
            font-weight: 600;
            letter-spacing: 0.1em;
            text-transform: uppercase;
            color: var(--cyan);
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            padding: 18px 0;
            transition: opacity 0.2s;
        }

        .manual-link:hover {
            opacity: 0.75;
        }

        /* ── FORM CARD ── */
        .form-card {
            width: 100%;
            max-width: 400px;
            background: rgba(12, 24, 22, 0.88);
            border: 1px solid var(--card-border);
            border-radius: 20px;
            padding: 32px 32px 28px;
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
            box-shadow:
                0 0 60px rgba(0, 217, 217, 0.06),
                0 24px 64px rgba(0,0,0,0.55);
            animation: slideUp 0.45s cubic-bezier(0.22, 1, 0.36, 1) both;
        }

        @keyframes slideUp {
            from { opacity: 0; transform: translateY(24px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        /* ── FORM FIELDS ── */
        .field {
            margin-bottom: 28px;
        }

        .field-label {
            display: block;
            font-size: 0.6875rem;
            font-weight: 600;
            letter-spacing: 0.1em;
            text-transform: uppercase;
            color: var(--label);
            margin-bottom: 8px;
        }

        .input-wrap {
            position: relative;
        }

        .input-wrap .icon {
            position: absolute;
            left: 14px;
            top: 50%;
            transform: translateY(-50%);
            width: 18px;
            height: 18px;
            color: rgba(255,255,255,0.35);
            pointer-events: none;
        }

        .input-wrap input {
            width: 100%;
            background: var(--input-bg);
            border: 1px solid var(--input-border);
            border-radius: 10px;
            padding: 13px 16px 13px 42px;
            font-size: 0.9375rem;
            color: rgba(255,255,255,0.7);
            font-family: inherit;
            outline: none;
            transition: border-color 0.25s, box-shadow 0.25s;
        }

        .input-wrap input::placeholder {
            color: rgba(255,255,255,0.25);
        }

        .input-wrap input:focus {
            border-color: rgba(0, 217, 217, 0.5);
            box-shadow: 0 0 0 3px rgba(0, 217, 217, 0.08);
        }

        /* ── LOGIN BUTTON ── */
        .btn-login {
            width: 100%;
            padding: 15px;
            border: none;
            border-radius: 10px;
            background: linear-gradient(90deg, #00b4b4 0%, #00e5c8 50%, #00ffcc 100%);
            color: #042020;
            font-size: 0.8125rem;
            font-weight: 800;
            letter-spacing: 0.12em;
            text-transform: uppercase;
            cursor: pointer;
            margin-top: 20px;
            transition: opacity 0.2s, transform 0.2s, box-shadow 0.2s;
            box-shadow: 0 4px 24px rgba(0, 220, 200, 0.35);
        }

        .btn-login:hover {
            opacity: 0.92;
            transform: translateY(-2px);
            box-shadow: 0 8px 32px rgba(0, 220, 200, 0.45);
        }

        .btn-login:active {
            transform: translateY(0);
        }

        /* ── FOOTER LINK ── */
        .footer-link {
            text-align: center;
            margin-top: 0;
            padding-top: 28px;
            padding-bottom: 8px;
            font-size: 0.8125rem;
            color: var(--muted);
        }

        .footer-link a {
            color: var(--cyan);
            font-weight: 600;
            text-decoration: none;
            margin-left: 4px;
            transition: opacity 0.2s;
        }

        .footer-link a:hover {
            opacity: 0.75;
        }

        /* ── VALIDATION ERRORS ── */
        .error-msg {
            color: #ff6b6b;
            font-size: 0.75rem;
            margin-top: 6px;
            display: block;
        }

        /* ── SVG ICON SIZE ── */
        .fb-icon {
            width: 20px;
            height: 20px;
            flex-shrink: 0;
        }

        /* ── RESPONSIVE ── */
        @media (max-width: 480px) {
            .page-title { font-size: 1.6rem; }
            .form-card  { padding: 24px 20px 20px; }
        }
    </style>
</head>
<body>
    <div class="page">

        <a href="/" class="site-logo">ALCHEMIST</a>

        <h1 class="page-title">Welcome <span>Back</span></h1>

        <div class="social-group">
            <a href="#" class="manual-link" id="toggle-manual" onclick="toggleForm(event)">Log In Manually</a>
        </div><div class="form-card" id="manual-form">
            <form method="POST" action="{{ route('login') }}">
                @csrf

                <div class="field">
                    <label class="field-label" for="email">Username</label>
                    <div class="input-wrap">
                        <svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
                            <circle cx="12" cy="8" r="4"/>
                            <path d="M4 20c0-4 3.6-7 8-7s8 3 8 7"/>
                        </svg>
                        <input
                            type="text"
                            id="email"
                            name="email"
                            placeholder="Nikola Tesla"
                            value="{{ old('email') }}"
                            autocomplete="username"
                            required
                        >
                    </div>
                    @error('email')
                        <span class="error-msg">{{ $message }}</span>
                    @enderror
                </div>

                <div class="field">
                    <label class="field-label" for="password">Password</label>
                    <div class="input-wrap">
                        <svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
                            <rect x="5" y="11" width="14" height="10" rx="2"/>
                            <path d="M8 11V7a4 4 0 0 1 8 0v4"/>
                        </svg>
                        <input
                            type="password"
                            id="password"
                            name="password"
                            placeholder="············"
                            autocomplete="current-password"
                            required
                        >
                    </div>
                    @error('password')
                        <span class="error-msg">{{ $message }}</span>
                    @enderror
                </div>

                <button type="submit" class="btn-login" id="btn-login-submit">
                    Login
                </button>
            </form>

            <p class="footer-link">
                Don't have an account?
                <a href="{{ route('register') }}">Sign Up →</a>
            </p>
        </div>

    </div>

    <script>
        function toggleForm(e) {
            e.preventDefault();
            const form = document.getElementById('manual-form');
            const link = document.getElementById('toggle-manual');
            const visible = form.style.display !== 'none';
            form.style.display = visible ? 'none' : 'block';
            link.textContent = visible ? 'Log In Manually' : 'Hide Form';
        }
    </script>
</body>
</html>