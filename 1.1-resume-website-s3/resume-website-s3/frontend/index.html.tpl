<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>John Doe - Full Stack Developer</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <!-- Header -->
    <header>
        <div class="container header-container">
            <div class="logo">John<span>Doe</span></div>
            <div class="menu-toggle">
                <i class="fas fa-bars"></i>
            </div>
            <nav>
                <ul>
                    <li><a href="#about">About</a></li>
                    <li><a href="#skills">Skills</a></li>
                    <li><a href="#projects">Projects</a></li>
                    <li><a href="#contact">Contact</a></li>
                </ul>
            </nav>
        </div>
    </header>

    <!-- Hero Section -->
    <section class="hero">
        <div class="container hero-content">
            <h1>Full Stack Developer & Cloud Engineer</h1>
            <p>I build scalable web applications and cloud infrastructure with modern technologies</p>
            <a href="#contact" class="btn">Get In Touch</a>
        </div>
    </section>

    <!-- About Section -->
    <section id="about">
        <div class="container">
            <div class="section-title">
                <h2>About Me</h2>
            </div>
            <div class="about-content">
                <div class="about-text">
                    <p>Hello! I'm John Doe, a passionate full-stack developer with expertise in JavaScript, Python, and cloud technologies. I enjoy building efficient, scalable applications that solve real-world problems.</p>
                    <p>With over 5 years of experience in the tech industry, I've worked on various projects ranging from small business websites to enterprise-level applications. I'm always eager to learn new technologies and take on challenging projects.</p>
                    <p>When I'm not coding, you can find me hiking, reading tech blogs, or contributing to open-source projects. I believe in writing clean, maintainable code and following best practices in software development.</p>
                </div>
                // <div class="about-img">
                //     <img src="https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=80" alt="John Doe">
                // </div>
            </div>
        </div>
    </section>

    <!-- Skills Section -->
    <section id="skills">
        <div class="container">
            <div class="section-title">
                <h2>My Skills</h2>
            </div>
            <div class="skills-container">
                <div class="skill-category">
                    <h3><i class="fas fa-code"></i> Frontend</h3>
                    <ul class="skill-list">
                        <li>JavaScript <div class="skill-level"><span style="width: 90%;"></span></div></li>
                        <li>React <div class="skill-level"><span style="width: 85%;"></span></div></li>
                        <li>HTML/CSS <div class="skill-level"><span style="width: 95%;"></span></div></li>
                    </ul>
                </div>
                <div class="skill-category">
                    <h3><i class="fas fa-server"></i> Backend</h3>
                    <ul class="skill-list">
                        <li>Python <div class="skill-level"><span style="width: 88%;"></span></div></li>
                        <li>Node.js <div class="skill-level"><span style="width: 80%;"></span></div></li>
                        <li>Express <div class="skill-level"><span style="width: 85%;"></span></div></li>
                    </ul>
                </div>
                <div class="skill-category">
                    <h3><i class="fas fa-cloud"></i> Cloud & DevOps</h3>
                    <ul class="skill-list">
                        <li>AWS <div class="skill-level"><span style="width: 85%;"></span></div></li>
                        <li>Terraform <div class="skill-level"><span style="width: 75%;"></span></div></li>
                        <li>Docker <div class="skill-level"><span style="width: 80%;"></span></div></li>
                    </ul>
                </div>
            </div>
        </div>
    </section>

    <!-- Projects Section -->
    <section id="projects">
        <div class="container">
            <div class="section-title">
                <h2>My Projects</h2>
            </div>
            <div class="projects-grid">
                <div class="project-card">
                    <div class="project-img">
                        <img src="https://images.unsplash.com/photo-1551650975-87deedd944c3?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=80" alt="E-commerce Platform">
                    </div>
                    <div class="project-info">
                        <h3>E-commerce Platform</h3>
                        <p>A full-stack e-commerce solution with React frontend and Node.js backend</p>
                        <div class="project-tags">
                            <span>React</span>
                            <span>Node.js</span>
                            <span>MongoDB</span>
                        </div>
                        <a href="#" class="btn">View Project</a>
                    </div>
                </div>
                <div class="project-card">
                    <div class="project-img">
                        <img src="https://images.unsplash.com/photo-1551288049-bebda4e38f71?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=80" alt="Cloud Infrastructure">
                    </div>
                    <div class="project-info">
                        <h3>Cloud Infrastructure</h3>
                        <p>Terraform modules for automated AWS infrastructure deployment</p>
                        <div class="project-tags">
                            <span>Terraform</span>
                            <span>AWS</span>
                            <span>CI/CD</span>
                        </div>
                        <a href="#" class="btn">View Project</a>
                    </div>
                </div>
                <div class="project-card">
                    <div class="project-img">
                        <img src="https://images.unsplash.com/photo-1550439062-609e1531270e?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=80" alt="Task Management App">
                    </div>
                    <div class="project-info">
                        <h3>Task Management App</h3>
                        <p>A productivity application with real-time updates and team collaboration</p>
                        <div class="project-tags">
                            <span>Vue.js</span>
                            <span>Firebase</span>
                            <span>WebSockets</span>
                        </div>
                        <a href="#" class="btn">View Project</a>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Visitor Counter -->
    <div class="container">
        <div class="visitor-counter">
            <h3>Visitor Count</h3>
            <p><span id="visitorCount">Loading...</span> people have visited this site</p>
        </div>
    </div>

    <!-- Contact Section -->
    <section id="contact">
        <div class="container">
            <div class="section-title">
                <h2>Contact Me</h2>
            </div>
            <div class="contact-container">
                <div class="contact-info">
                    <h3>Get In Touch</h3>
                    <ul class="contact-details">
                        <li>
                            <i class="fas fa-envelope"></i>
                            <span>john.doe@example.com</span>
                        </li>
                        <li>
                            <i class="fas fa-phone"></i>
                            <span>+1 (123) 456-7890</span>
                        </li>
                        <li>
                            <i class="fas fa-map-marker-alt"></i>
                            <span>San Francisco, CA</span>
                        </li>
                    </ul>
                </div>
                <div class="contact-form">
                    <form id="contactForm">
                        <div class="form-group">
                            <label for="name">Name</label>
                            <input type="text" id="name" required>
                        </div>
                        <div class="form-group">
                            <label for="email">Email</label>
                            <input type="email" id="email" required>
                        </div>
                        <div class="form-group">
                            <label for="message">Message</label>
                            <textarea id="message" required></textarea>
                        </div>
                        <button type="submit" class="btn">Send Message</button>
                        <p id="formStatus"></p>
                    </form>
                </div>
            </div>
        </div>
    </section>

    <!-- Analytics Section -->
    <div class="container">
        <div id="analyticsSection" style="display: none;">
            <div class="section-title">
                <h2>Website Analytics</h2>
            </div>
            <div class="chart-container">
                <canvas id="visitorChart"></canvas>
            </div>
        </div>
    </div>

    <!-- Footer -->
    <footer>
        <div class="container">
            <div class="social-links">
                <a href="#"><i class="fab fa-github"></i></a>
                <a href="#"><i class="fab fa-linkedin"></i></a>
                <a href="#"><i class="fab fa-twitter"></i></a>
                <a href="#"><i class="fab fa-dev"></i></a>
            </div>
            <p>&copy; 2023 John Doe. All rights reserved.</p>
        </div>
    </footer>

<script src="script.js"></script>
</body>
</html>