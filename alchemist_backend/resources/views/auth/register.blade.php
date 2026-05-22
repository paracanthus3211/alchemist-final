<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Create Account - Alchemist</title>
    <meta name="description" content="Create your Alchemist account and master the elements of your future.">

    <!-- Google Fonts -->
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
            --bg:        #0a0e0f;
            --card-bg:   #0f1a1a;
            --card-border: rgba(0, 200, 170, 0.12);
            --input-bg:  #152020;
            --input-border: rgba(255,255,255,0.07);
            --cyan:      #00d9d9;
            --cyan-2:    #00ffcc;
            --accent:    #e066ff;
            --yellow:    #d4ff00;
            --white:     #ffffff;
            --muted:     rgba(255,255,255,0.45);
            --label:     rgba(255,255,255,0.55);
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
            backdrop-filter: blur(0px);
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
            margin-bottom: 20px;
        }

        /* ── DIVIDER ── */
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

            /* animate in */
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

        /* ── REGISTER BUTTON ── */
        .btn-register {
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

        .btn-register:hover {
            opacity: 0.92;
            transform: translateY(-2px);
            box-shadow: 0 8px 32px rgba(0, 220, 200, 0.45);
        }

        .btn-register:active {
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

        /* ── SOCIAL ICON SVGS ── */
        .fb-icon {
            width: 20px;
            height: 20px;
            flex-shrink: 0;
        }

        /* ── VALIDATION ERRORS ── */
        .error-msg {
            color: #ff6b6b;
            font-size: 0.75rem;
            margin-top: 6px;
            display: block;
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

        /* ── SOCIAL GROUP ── */
        .social-group {
            width: 100%;
            max-width: 400px;
            display: flex;
            flex-direction: column;
            align-items: center;
            margin-bottom: 40px;
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

        <!-- Logo -->
        <a href="/" class="site-logo">ALCHEMIST</a>

        <!-- Title -->
        <h1 class="page-title">Create Your <span>Account</span></h1>

        <!-- Social Buttons + Manual toggle -->
        <div class="social-group">
        <a href="#" id="btn-facebook" class="social-btn btn-facebook">
            <!-- Facebook icon -->
            <svg class="fb-icon" viewBox="0 0 24 24" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
                <path d="M24 12.073C24 5.404 18.627 0 12 0S0 5.404 0 12.073C0 18.1 4.388 23.094 10.125 24v-8.437H7.078v-3.49h3.047V9.41c0-3.025 1.791-4.697 4.533-4.697 1.312 0 2.686.236 2.686.236v2.97h-1.513c-1.491 0-1.956.93-1.956 1.885v2.271h3.328l-.532 3.49h-2.796V24C19.612 23.094 24 18.1 24 12.073Z"/>
            </svg>
            Continue with Facebook
        </a>

        <a href="#" id="btn-google" class="social-btn btn-google">
            <!-- Google icon -->
            <svg class="fb-icon" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4"/>
                <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853"/>
                <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z" fill="#FBBC05"/>
                <path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335"/>
            </svg>
            Continue with Google
        </a>

        <!-- Manual signup toggle -->
        <a href="#" class="manual-link" id="toggle-manual" onclick="toggleForm(event)">Sign Up Manually</a>
        </div><!-- end .social-group -->

        <!-- Form Card -->
        <div class="form-card" id="manual-form">
            <form method="POST" action="{{ route('register') }}">
                @csrf

                <!-- Username -->
                <div class="field">
                    <label class="field-label" for="name">Username</label>
                    <div class="input-wrap">
                        <!-- Person icon -->
                        <svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
                            <circle cx="12" cy="8" r="4"/>
                            <path d="M4 20c0-4 3.6-7 8-7s8 3 8 7"/>
                        </svg>
                        <input
                            type="text"
                            id="name"
                            name="name"
                            placeholder="Nikola Tesla"
                            value="{{ old('name') }}"
                            autocomplete="name"
                            required
                        >
                    </div>
                    @error('name')
                        <span class="error-msg">{{ $message }}</span>
                    @enderror
                </div>

                <!-- Email -->
                <div class="field">
                    <label class="field-label" for="email">Email Address</label>
                    <div class="input-wrap">
                        <!-- Envelope icon -->
                        <svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
                            <rect x="2" y="4" width="20" height="16" rx="2"/>
                            <path d="M2 8l10 6 10-6"/>
                        </svg>
                        <input
                            type="email"
                            id="email"
                            name="email"
                            placeholder="scientist@alchemist.io"
                            value="{{ old('email') }}"
                            autocomplete="email"
                            required
                        >
                    </div>
                    @error('email')
                        <span class="error-msg">{{ $message }}</span>
                    @enderror
                </div>

                <!-- Password -->
                <div class="field">
                    <label class="field-label" for="password">Password</label>
                    <div class="input-wrap">
                        <!-- Lock icon -->
                        <svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
                            <rect x="5" y="11" width="14" height="10" rx="2"/>
                            <path d="M8 11V7a4 4 0 0 1 8 0v4"/>
                        </svg>
                        <input
                            type="password"
                            id="password"
                            name="password"
                            placeholder="············"
                            autocomplete="new-password"
                            required
                        >
                    </div>
                    @error('password')
                        <span class="error-msg">{{ $message }}</span>
                    @enderror
                </div>

                <!-- Hidden confirm password (same value forwarded) -->
                <input type="hidden" name="password_confirmation" id="password_confirm">

                <!-- Submit -->
                <button type="submit" class="btn-register" id="btn-register">
                    Register Account
                </button>
            </form>

            <!-- Footer -->
            <p class="footer-link">
                Already have an account?
                <a href="{{ route('login') }}">Log In →</a>
            </p>
        </div>

    </div>

    <script>
        // Auto-sync password_confirmation with password
        document.getElementById('password').addEventListener('input', function () {
            document.getElementById('password_confirm').value = this.value;
        });

        // Toggle manual form visibility
        function toggleForm(e) {
            e.preventDefault();
            const form = document.getElementById('manual-form');
            const link = document.getElementById('toggle-manual');
            const visible = form.style.display !== 'none';
            form.style.display = visible ? 'none' : 'block';
            link.textContent = visible ? 'Sign Up Manually' : 'Hide Form';
        }
    </script>
</body>
</html>
