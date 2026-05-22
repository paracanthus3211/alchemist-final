<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Alchemist - Master the Elements of Your Future</title>
    <meta name="description" content="Thousands of people are using Alchemist for study. Master the elements of your future.">
    
    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300;400;500;600;700&family=Silkscreen&display=swap" rel="stylesheet">
    
    <style>
        /* CSS Reset & Variables */
        *, *::before, *::after {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        :root {
            --background: #0B1114;
            --foreground: #ffffff;
            --card: #131b1f;
            --muted: #1a2428;
            --muted-foreground: #8a9a9a;
            --primary: #d4ff00;
            --secondary: #00d9d9;
            --accent: #e066ff;
            --border: #1a2428;
            --olive: #7a8a00;
        }

        html {
            scroll-behavior: smooth;
        }

        body {
            font-family: 'Space Grotesk', sans-serif;
            background-color: var(--background);
            background-image: 
                radial-gradient(circle at 0% 0%, rgba(106, 13, 173, 0.03) 0%, transparent 50%),
                radial-gradient(circle at 100% 100%, rgba(75, 0, 130, 0.03) 0%, transparent 50%);
            color: var(--foreground);
            line-height: 1.6;
            overflow-x: hidden;
            position: relative;
        }

        /* Background Decorations */
        .bg-decorations {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: -1;
            overflow: hidden;
            pointer-events: none;
        }

        .blob {
            position: absolute;
            border-radius: 50%;
            filter: blur(120px);
            opacity: 0.1;
            animation: float 25s infinite alternate ease-in-out;
        }

        .blob-1 {
            width: 600px;
            height: 600px;
            background: #4b0082; /* Indigo/Dark Purple */
            top: -200px;
            right: -100px;
        }

        .blob-2 {
            width: 700px;
            height: 700px;
            background: #2e0854; /* Very Dark Purple */
            bottom: -200px;
            left: -200px;
            animation-delay: -7s;
        }

        .blob-3 {
            width: 400px;
            height: 400px;
            background: var(--secondary);
            top: 40%;
            left: 60%;
            opacity: 0.1;
            animation-delay: -12s;
        }

        .particle {
            position: absolute;
            background: #4b0082;
            border-radius: 50%;
            opacity: 0.15;
            animation: float-particle 15s infinite linear;
        }

        .particle-1 { width: 4px; height: 4px; top: 20%; left: 10%; animation-duration: 20s; }
        .particle-2 { width: 6px; height: 6px; top: 60%; left: 80%; animation-duration: 25s; animation-delay: -5s; }
        .particle-3 { width: 3px; height: 3px; top: 40%; left: 30%; animation-duration: 18s; animation-delay: -2s; }
        .particle-4 { width: 5px; height: 5px; top: 80%; left: 20%; animation-duration: 22s; animation-delay: -8s; }

        @keyframes float-particle {
            0% { transform: translateY(0) translateX(0); opacity: 0; }
            50% { opacity: 0.3; }
            100% { transform: translateY(-100px) translateX(20px); opacity: 0; }
        }

        .bg-grid {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-image: radial-gradient(rgba(255, 255, 255, 0.03) 1px, transparent 1px);
            background-size: 40px 40px;
            z-index: -1;
        }

        @keyframes float {
            0% { transform: translate(0, 0) scale(1) rotate(0deg); }
            33% { transform: translate(50px, 80px) scale(1.1) rotate(10deg); }
            66% { transform: translate(-30px, 40px) scale(0.9) rotate(-10deg); }
            100% { transform: translate(0, 0) scale(1) rotate(0deg); }
        }

        .container {
            max-width: 1280px;
            margin: 0 auto;
            padding: 0 60px;
        }

        a {
            text-decoration: none;
            color: inherit;
        }

        ul {
            list-style: none;
        }

        img {
            max-width: 100%;
            height: auto;
        }

        /* Header */
        .header {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            z-index: 50;
            background-color: var(--background);
            border-bottom: 1px solid rgba(255, 255, 255, 0.05);
        }

        .header .container {
            padding-top: 24px;
            padding-bottom: 24px;
        }

        .header nav {
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .logo {
            font-family: 'Silkscreen', cursive;
            font-size: 1.25rem;
            font-weight: 400;
            letter-spacing: 0.1em;
            color: var(--foreground);
            text-shadow: 0 0 10px rgba(75, 0, 130, 0.3);
        }

        .nav-links {
            display: none;
            align-items: center;
            gap: 32px;
        }

        .nav-links a {
            color: rgba(255, 255, 255, 0.6);
            font-size: 0.9375rem;
            transition: color 0.2s ease;
            font-weight: 400;
        }

        .nav-links a:hover {
            color: var(--foreground);
        }

        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 10px 20px;
            border-radius: 8px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.2s ease;
            border: none;
            font-size: 14px;
        }

        .btn-outline {
            background: transparent;
            border: 1px solid rgba(255, 255, 255, 0.4);
            color: var(--foreground);
            border-radius: 4px;
            padding: 8px 24px;
        }

        .btn-outline:hover {
            border-color: var(--foreground);
        }

        .btn-primary {
            background: var(--secondary);
            color: var(--background);
        }

        .btn-primary:hover {
            background: rgba(0, 217, 217, 0.9);
            box-shadow: 0 0 20px rgba(75, 0, 130, 0.2);
            transform: translateY(-2px);
        }

        .lang-selector {
            color: rgba(255, 255, 255, 0.6);
            font-size: 14px;
        }

        .mobile-menu-btn {
            display: flex;
            align-items: center;
            justify-content: center;
            background: none;
            border: none;
            color: var(--foreground);
            cursor: pointer;
            padding: 8px;
        }

        /* Hero Section */
        .hero {
            min-height: 100vh;
            display: flex;
            align-items: center;
            padding-top: 100px;
        }

        .hero-grid {
            display: grid;
            grid-template-columns: 1fr;
            gap: 48px;
            align-items: center;
        }

        .hero-content {
            display: flex;
            flex-direction: column;
            gap: 24px;
        }

        .hero h1 {
            font-size: 3rem;
            font-weight: 700;
            line-height: 1.1;
            margin-bottom: 32px;
        }

        .hero h1 .primary {
            color: var(--secondary);
        }

        .hero h1 .secondary {
            color: var(--primary);
        }

        .hero p {
            color: rgba(255, 255, 255, 0.6);
            font-size: 1.125rem;
            max-width: 480px;
            line-height: 1.8;
        }

        .hero-image {
            display: flex;
            justify-content: center;
            position: relative;
        }

        .hero-image::after {
            content: '';
            position: absolute;
            width: 80%;
            height: 80%;
            background: #4b0082;
            filter: blur(140px);
            opacity: 0.15;
            z-index: -1;
            border-radius: 50%;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
        }

        .hero-image img {
            max-width: 100%;
            height: auto;
            position: relative;
            z-index: 1;
        }

        /* About Section */
        .about {
            padding: 120px 0;
        }

        .about-intro {
            max-width: 1000px;
            margin-bottom: 100px;
        }

        .about-intro p {
            color: rgba(255, 255, 255, 0.6);
            font-size: 1.35rem;
            line-height: 1.8;
            font-weight: 400;
            letter-spacing: 0.02em;
        }

        .features-title {
            font-size: 2.5rem;
            font-weight: 700;
            margin-bottom: 64px;
            color: var(--foreground);
        }

        .features-list {
            display: flex;
            flex-direction: column;
            gap: 120px;
        }

        .feature-item h3 {
            font-size: 1.75rem;
            font-weight: 500;
            color: var(--foreground);
            margin-bottom: 32px;
        }

        .feature-item-content {
            display: grid;
            grid-template-columns: 1fr;
            gap: 48px;
            align-items: center;
        }

        @media (min-width: 768px) {
            .feature-item-content {
                grid-template-columns: 350px 1fr;
            }
        }

        .feature-image {
            border-radius: 16px;
            overflow: hidden;
            background: var(--card);
            line-height: 0;
        }

        .feature-image img {
            width: 100%;
            height: auto;
            display: block;
        }

        .feature-points {
            display: flex;
            flex-direction: column;
            gap: 20px;
        }

        .feature-points p {
            color: rgba(255, 255, 255, 0.6);
            font-size: 1rem;
            line-height: 1.6;
        }

        /* Contact Section */
        .contact {
            padding: 96px 0;
        }

        .contact-card {
            max-width: 560px;
            margin: 0 auto;
            background: rgba(19, 27, 31, 0.8);
            backdrop-filter: blur(12px);
            border: 1px solid rgba(75, 0, 130, 0.15);
            border-radius: 24px;
            padding: 48px;
            position: relative;
            overflow: hidden;
        }

        .contact-card::before {
            content: '';
            position: absolute;
            top: -50%;
            left: -50%;
            width: 100%;
            height: 100%;
            background: radial-gradient(circle, rgba(224, 102, 255, 0.1) 0%, transparent 70%);
            pointer-events: none;
        }

        .contact-card h2 {
            font-size: 1.5rem;
            font-weight: 600;
            color: var(--foreground);
            margin-bottom: 40px;
            position: relative;
        }

        .contact-form {
            display: flex;
            flex-direction: column;
            gap: 24px;
        }

        .input-wrapper {
            position: relative;
        }

        .input-wrapper svg {
            position: absolute;
            left: 16px;
            top: 50%;
            transform: translateY(-50%);
            width: 20px;
            height: 20px;
            color: rgba(26, 43, 43, 0.6);
        }

        .input-wrapper input {
            width: 100%;
            padding: 16px 16px 16px 48px;
            border-radius: 12px;
            border: none;
            background: white;
            font-size: 1rem;
            color: var(--background);
        }

        .input-wrapper input::placeholder {
            color: rgba(26, 43, 43, 0.5);
        }

        .contact-form textarea {
            width: 100%;
            padding: 16px;
            border-radius: 12px;
            border: none;
            background: white;
            font-size: 1rem;
            color: var(--background);
            resize: none;
            min-height: 150px;
            font-family: inherit;
        }

        .contact-form textarea::placeholder {
            color: rgba(26, 43, 43, 0.5);
        }

        .contact-form .btn-primary {
            padding: 16px 32px;
            border-radius: 12px;
            font-size: 1rem;
            align-self: flex-start;
        }

        /* Footer */
        .footer {
            border-top: 1px solid rgba(255, 255, 255, 0.05);
            padding: 64px 0;
        }

        .footer-content {
            display: flex;
            flex-direction: column;
            gap: 48px;
        }

        .footer-left {
            max-width: 350px;
        }

        .footer-left .logo {
            display: inline-block;
            margin-bottom: 16px;
        }

        .footer-left p {
            color: rgba(255, 255, 255, 0.6);
            line-height: 1.6;
        }

        .footer-right {
            display: flex;
            flex-direction: column;
            gap: 32px;
        }

        .social-links {
            display: flex;
            align-items: center;
            gap: 16px;
        }

        .social-link {
            width: 56px;
            height: 56px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: opacity 0.2s ease;
        }

        .social-link:hover {
            opacity: 0.8;
        }

        .social-link.facebook {
            background: var(--muted);
        }

        .social-link.instagram {
            background: linear-gradient(135deg, #f09433 0%, #e6683c 25%, #dc2743 50%, #cc2366 75%, #bc1888 100%);
        }

        .social-link.twitter {
            background: white;
        }

        .social-link svg {
            width: 20px;
            height: 20px;
        }

        .social-link.facebook svg,
        .social-link.instagram svg {
            color: white;
        }

        .social-link.twitter svg {
            color: var(--background);
        }

        .app-section h4 {
            color: rgba(255, 255, 255, 0.6);
            margin-bottom: 16px;
            font-weight: 400;
        }

        .app-buttons {
            display: flex;
            flex-wrap: wrap;
            gap: 16px;
        }

        .app-btn {
            display: flex;
            align-items: center;
            gap: 12px;
            background: #1a1a1a;
            padding: 12px 16px;
            border-radius: 8px;
            transition: background 0.2s ease;
        }

        .app-btn:hover {
            background: #2a2a2a;
        }

        .app-btn svg {
            width: 24px;
            height: 24px;
        }

        .app-btn-text {
            text-align: left;
        }

        .app-btn-text span {
            display: block;
            font-size: 10px;
            color: rgba(255, 255, 255, 0.6);
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }

        .app-btn-text strong {
            display: block;
            font-size: 14px;
            font-weight: 500;
            color: var(--foreground);
        }

        .footer-bottom {
            margin-top: 64px;
            padding-top: 32px;
            border-top: 1px solid rgba(255, 255, 255, 0.05);
            text-align: center;
        }

        .footer-bottom p {
            color: rgba(255, 255, 255, 0.6);
        }

        /* Mobile Menu */
        .mobile-menu {
            display: none;
            position: fixed;
            top: 70px;
            left: 0;
            right: 0;
            background: var(--background);
            padding: 24px;
            border-bottom: 1px solid var(--border);
            flex-direction: column;
            gap: 16px;
            z-index: 40;
        }

        .mobile-menu.active {
            display: flex;
        }

        .mobile-menu a {
            padding: 12px 0;
            color: rgba(255, 255, 255, 0.8);
            border-bottom: 1px solid var(--border);
        }

        .mobile-menu .btn {
            margin-top: 8px;
        }

        /* Responsive */
        @media (min-width: 768px) {
            .hero h1 {
                font-size: 3.5rem;
            }

            .contact-card {
                padding: 48px 64px;
            }

            .contact-card h2 {
                font-size: 1.75rem;
            }
        }

        @media (min-width: 1024px) {
            .nav-links {
                display: flex;
            }

            .mobile-menu-btn {
                display: none;
            }

            .hero-grid {
                grid-template-columns: 1fr 1fr;
            }

            .hero h1 {
                font-size: 3.75rem;
            }

            .hero-image {
                justify-content: flex-end;
            }

            .features-grid {
                grid-template-columns: 1fr 1fr;
            }

            .footer-content {
                flex-direction: row;
                justify-content: space-between;
            }
        }
    </style>
</head>
<body>
    <!-- Background Decorations -->
    <div class="bg-decorations">
        <div class="bg-grid"></div>
        <div class="blob blob-1"></div>
        <div class="blob blob-2"></div>
        <div class="blob blob-3"></div>
        <div class="particle particle-1"></div>
        <div class="particle particle-2"></div>
        <div class="particle particle-3"></div>
        <div class="particle particle-4"></div>
    </div>

    <!-- Header -->
    <header class="header">
        <div class="container">
            <nav>
                <a href="/" class="logo">ALCHEMIST</a>
                
                <div class="nav-links">
                    <a href="#contact">Contact</a>
                    <a href="#about">About</a>
                    @auth
                        <a href="{{ route('home') }}">Dashboard</a>
                        <form method="POST" action="{{ route('logout') }}" style="display:inline">
                            @csrf
                            <button type="submit" class="btn btn-outline" style="cursor:pointer;font-family:inherit">Logout</button>
                        </form>
                    @else
                        <a href="{{ route('login') }}">Log In</a>
                        <a href="{{ route('register') }}" class="btn btn-outline">Sign Up</a>
                    @endauth
                    <span class="lang-selector">EN</span>
                </div>

                <button class="mobile-menu-btn" onclick="toggleMobileMenu()">
                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <line x1="3" y1="12" x2="21" y2="12"></line>
                        <line x1="3" y1="6" x2="21" y2="6"></line>
                        <line x1="3" y1="18" x2="21" y2="18"></line>
                    </svg>
                </button>
            </nav>
        </div>
    </header>

    <!-- Mobile Menu -->
    <div class="mobile-menu" id="mobileMenu">
        <a href="#contact" onclick="closeMobileMenu()">Contact</a>
        <a href="#about" onclick="closeMobileMenu()">About</a>
        @auth
            <a href="{{ route('home') }}">Dashboard</a>
            <form method="POST" action="{{ route('logout') }}" style="margin:0">
                @csrf
                <button type="submit" class="btn btn-outline" style="cursor:pointer;font-family:inherit;width:100%">Logout</button>
            </form>
        @else
            <a href="{{ route('login') }}">Log In</a>
            <a href="{{ route('register') }}" class="btn btn-outline">Sign Up</a>
        @endauth
    </div>

    <!-- Hero Section -->
    <section class="hero">
        <div class="container">
            <div class="hero-grid">
                <div class="hero-content">
                    <h1>
                        We are <span class="secondary">what</span><br>
                        we <span class="primary">do</span>
                    </h1>
                    <p>Thousands of people are using Alchemist for study. Master the elements of your future.</p>
                </div>
                
                <div class="hero-image">
                    <img 
                        src="https://hebbkx1anhila5yf.public.blob.vercel-storage.com/Group%206959%20%282%29-l8xRgKwcVOPhtvbcBvLGWjKeq7hKGy.png" 
                        alt="Alchemist scientist with colorful beakers and robot assistant"
                        width="600"
                        height="500"
                    >
                </div>
            </div>
        </div>
    </section>

    <!-- About Section -->
    <section class="about" id="about">
        <div class="container">
            <div class="about-intro">
                <p>Alchemist is an interactive chemistry learning platform that combines theory and practice in one place. We believe that chemistry is not just about memorizing formulas, but also about exploration and discovery. With a fun and immersive approach, Alchemist is designed for all levels of learners—from beginners to science enthusiasts.</p>
            </div>

            <div>
                <h2 class="features-title">Best feature</h2>

                <div class="features-list">
                    <!-- Virtual Lab -->
                    <div class="feature-item">
                        <h3>virtual lab</h3>
                        <div class="feature-item-content">
                            <div class="feature-image">
                                <img 
                                    src="https://hebbkx1anhila5yf.public.blob.vercel-storage.com/Screenshot%202026-05-12%20194053%202-yo6VCxE2SRPQ8XhylNUQJIj6ereiKZ.png" 
                                    alt="Virtual Lab Interface showing admin panel with chapter progress and achievement badge"
                                >
                            </div>
                            <div class="feature-points">
                                <p>Mix chemical compounds safely and in real time.</p>
                                <p>Observe reactions such as color changes, gas changes, or precipitates.</p>
                                <p>Perform experiments repeatedly without risk of harm.</p>
                                <p>Visually understand the concepts of stoichiometry, titration, and thermochemistry.</p>
                            </div>
                        </div>
                    </div>

                    <!-- Quiz -->
                    <div class="feature-item">
                        <h3>Quiz</h3>
                        <div class="feature-item-content">
                            <div class="feature-image">
                                <img 
                                    src="https://hebbkx1anhila5yf.public.blob.vercel-storage.com/Screenshot%202026-05-12%20193017%201-2JROGPEA1y2agiib7A9dHYypwRqDkR.png" 
                                    alt="Quiz interface with beakers containing HCL and NaOH, test tubes, and orange indicator"
                                >
                            </div>
                            <div class="feature-points">
                                <p>Questions with varying difficulty levels (beginner, intermediate, advanced).</p>
                                <p>Immediate feedback and discussion of each answer.</p>
                                <p>Various question formats: multiple choice, short answer, and case studies.</p>
                                <p>Leaderboards and achievements to motivate your learning.</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Contact Section -->
    <section class="contact" id="contact">
        <div class="container">
            <div class="contact-card">
                <h2>Send us a message via Email</h2>

                <form class="contact-form" onsubmit="handleSubmit(event)">
                    <div class="input-wrapper">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <rect width="20" height="16" x="2" y="4" rx="2"/>
                            <path d="m22 7-8.97 5.7a1.94 1.94 0 0 1-2.06 0L2 7"/>
                        </svg>
                        <input type="email" name="email" placeholder="your email" required>
                    </div>

                    <textarea name="message" placeholder="your message" rows="6" required></textarea>

                    <button type="submit" class="btn btn-primary">Send message</button>
                </form>
            </div>
        </div>
    </section>

    <!-- Footer -->
    <footer class="footer">
        <div class="container">
            <div class="footer-content">
                <!-- Left Side -->
                <div class="footer-left">
                    <a href="/" class="logo">ALCHEMIST</a>
                    <p>Learn chemistry using interactive games, quiz and lab virtual</p>
                </div>

                <!-- Right Side -->
                <div class="footer-right">
                    <!-- Social Links -->
                    <div class="social-links">
                        <a href="#" class="social-link facebook" aria-label="Facebook">
                            <svg fill="currentColor" viewBox="0 0 24 24">
                                <path d="M18 2h-3a5 5 0 0 0-5 5v3H7v4h3v8h4v-8h3l1-4h-4V7a1 1 0 0 1 1-1h3z"/>
                            </svg>
                        </a>

                        <a href="#" class="social-link instagram" aria-label="Instagram">
                            <svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                                <rect x="2" y="2" width="20" height="20" rx="5" ry="5"/>
                                <circle cx="12" cy="12" r="4"/>
                                <circle cx="18" cy="6" r="1.5" fill="currentColor"/>
                            </svg>
                        </a>

                        <a href="#" class="social-link twitter" aria-label="Twitter">
                            <svg fill="currentColor" viewBox="0 0 24 24">
                                <path d="M23 3a10.9 10.9 0 0 1-3.14 1.53 4.48 4.48 0 0 0-7.86 3v1A10.66 10.66 0 0 1 3 4s-4 9 5 13a11.64 11.64 0 0 1-7 2c9 5 20 0 20-11.5a4.5 4.5 0 0 0-.08-.83A7.72 7.72 0 0 0 23 3z"/>
                            </svg>
                        </a>
                    </div>

                    <!-- App Section -->
                    <div class="app-section">
                        <h4>Discover our app</h4>
                        
                        <div class="app-buttons">
                            <a href="#" class="app-btn">
                                <svg viewBox="0 0 24 24">
                                    <path fill="#4285F4" d="M3.609 1.814L13.792 12 3.61 22.186a.996.996 0 0 1-.61-.92V2.734a1 1 0 0 1 .609-.92z"/>
                                    <path fill="#34A853" d="M14.5 12.707l2.302 2.302-10.937 6.333a1 1 0 0 1-.255.076l8.89-8.711z"/>
                                    <path fill="#FBBC04" d="M19.443 10.187l-2.64 1.52L14.5 9.293l-8.89-8.711a1 1 0 0 1 .255.076l10.937 6.333 2.64 1.52.001.001z"/>
                                    <path fill="#EA4335" d="M19.443 10.187L16.802 11.707 14.5 9.293l8.89-8.711z"/>
                                </svg>
                                <div class="app-btn-text">
                                    <span>GET IT ON</span>
                                    <strong>GOOGLE PLAY</strong>
                                </div>
                            </a>

                            <a href="#" class="app-btn">
                                <svg fill="white" viewBox="0 0 24 24">
                                    <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z"/>
                                </svg>
                                <div class="app-btn-text">
                                    <span>Avalible on the</span>
                                    <strong>Apple Store</strong>
                                </div>
                            </a>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Copyright -->
            <div class="footer-bottom">
                <p>All rights reserved@alchemist.com</p>
            </div>
        </div>
    </footer>

    <script>
        // Mobile Menu Toggle
        function toggleMobileMenu() {
            const mobileMenu = document.getElementById('mobileMenu');
            mobileMenu.classList.toggle('active');
        }

        function closeMobileMenu() {
            const mobileMenu = document.getElementById('mobileMenu');
            mobileMenu.classList.remove('active');
        }

        // Form Submit Handler
        function handleSubmit(event) {
            event.preventDefault();
            const formData = new FormData(event.target);
            const email = formData.get('email');
            const message = formData.get('message');
            
            // Replace with your Laravel route
            // Example using fetch:
            /*
            fetch('/api/contact', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').content
                },
                body: JSON.stringify({ email, message })
            })
            .then(response => response.json())
            .then(data => {
                alert('Message sent successfully!');
                event.target.reset();
            })
            .catch(error => {
                console.error('Error:', error);
                alert('Failed to send message. Please try again.');
            });
            */
            
            alert('Message sent! (Demo mode - connect to Laravel backend)');
            event.target.reset();
        }

        // Smooth scroll for anchor links
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function (e) {
                e.preventDefault();
                const target = document.querySelector(this.getAttribute('href'));
                if (target) {
                    target.scrollIntoView({
                        behavior: 'smooth',
                        block: 'start'
                    });
                }
            });
        });
    </script>
</body>
</html>
