// // Flask backend URL - default to current origin for EC2 deployment
var backend_url = window.location.origin;

// Section highlight in nav (if nav exists)
document.addEventListener('DOMContentLoaded', function() {
    // Mobile navigation toggle
    const hamburger = document.querySelector('.hamburger');
    const navMenu = document.querySelector('.nav-menu');
    
    if (hamburger && navMenu) {
        hamburger.addEventListener('click', function() {
            hamburger.classList.toggle('active');
            navMenu.classList.toggle('active');
        });

        // Close mobile menu when clicking on a nav link
        document.querySelectorAll('.nav-link').forEach(link => {
            link.addEventListener('click', () => {
                hamburger.classList.remove('active');
                navMenu.classList.remove('active');
            });
        });
    }

    // Highlight current section in view
    if (window.IntersectionObserver) {
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    document.querySelectorAll('.nav-link').forEach(link => {
                        link.classList.remove('active');
                        if (link.getAttribute('href') === `#${entry.target.id}`) {
                            link.classList.add('active');
                        }
                    });
                }
            });
        }, {threshold: 0.7});
        
        document.querySelectorAll('section[id]').forEach(section => {
            observer.observe(section);
        });
    }

    // Navbar scroll effect
    window.addEventListener('scroll', function() {
        const navbar = document.getElementById('navbar');
        if (navbar) {
            if (window.scrollY > 50) {
                navbar.classList.add('scrolled');
            } else {
                navbar.classList.remove('scrolled');
            }
        }
    });

    // Initialize visitor count and show analytics if admin
    updateVisitorCount();
    
    // Check for admin mode
    if (location.hash === '#admin') {
        showAnalytics();
    }
});

// Update visitor count
async function updateVisitorCount() {
    try {
        const apiUrl = backend_url + '/api/visitor';
        const response = await fetch(apiUrl);
        const data = await response.json();
        
        const visitorCountElement = document.getElementById('visitorCount');
        if (visitorCountElement) {
            visitorCountElement.textContent = data.count;
        }
    } catch (error) {
        console.error('Error fetching visitor count:', error);
        const visitorCountElement = document.getElementById('visitorCount');
        if (visitorCountElement) {
            visitorCountElement.textContent = 'Error';
        }
    }
}

// Contact form submission
if (document.getElementById('contactForm')) {
    document.getElementById('contactForm').addEventListener('submit', async (e) => {
        e.preventDefault();
        
        const formData = {
            name: document.getElementById('name').value,
            email: document.getElementById('email').value,
            message: document.getElementById('message').value
        };
        
        const formStatus = document.getElementById('formStatus');
        const submitButton = e.target.querySelector('button[type="submit"]');
        
        // Show loading state
        if (submitButton) {
            submitButton.disabled = true;
            submitButton.textContent = 'Sending...';
        }
        
        try {
            const response = await fetch(backend_url + '/api/contact', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(formData)
            });
            
            const result = await response.json();
            
            if (formStatus) {
                if (response.ok) {
                    formStatus.textContent = 'Message sent successfully!';
                    formStatus.style.color = 'var(--success)';
                    document.getElementById('contactForm').reset();
                    
                    // Clear success message after 5 seconds
                    setTimeout(() => {
                        formStatus.textContent = '';
                    }, 5000);
                } else {
                    formStatus.textContent = `Error: ${result.error || 'Failed to send message'}`;
                    formStatus.style.color = 'var(--accent)';
                }
            }
        } catch (error) {
            console.error('Error sending message:', error);
            if (formStatus) {
                formStatus.textContent = 'Error sending message. Please try again.';
                formStatus.style.color = 'var(--accent)';
            }
        } finally {
            // Reset button state
            if (submitButton) {
                submitButton.disabled = false;
                submitButton.textContent = 'Send Message';
            }
        }
    });
}

// Show analytics section (admin mode)
function showAnalytics() {
    const analyticsSection = document.getElementById('analyticsSection');
    if (analyticsSection) {
        analyticsSection.style.display = 'block';
        loadAnalyticsChart();
    }
}

// Load analytics chart
function loadAnalyticsChart() {
    const canvas = document.getElementById('visitorChart');
    if (!canvas) return;
    
    // Sample data for visitor analytics
    const visitorData = {
        labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
        datasets: [{
            label: 'Visitors',
            data: [12, 19, 13, 15, 22, 13, 8],
            borderColor: 'rgb(96, 165, 250)',
            backgroundColor: 'rgba(96, 165, 250, 0.1)',
            borderWidth: 2,
            fill: true,
            tension: 0.4
        }]
    };
    
    const config = {
        type: 'line',
        data: visitorData,
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    labels: {
                        color: 'var(--text-primary)'
                    }
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    grid: {
                        color: 'var(--border-color)'
                    },
                    ticks: {
                        color: 'var(--text-secondary)'
                    }
                },
                x: {
                    grid: {
                        color: 'var(--border-color)'
                    },
                    ticks: {
                        color: 'var(--text-secondary)'
                    }
                }
            }
        }
    };
    
    // Destroy existing chart if it exists
    if (window.visitorChart instanceof Chart) {
        window.visitorChart.destroy();
    }
    
    // Create new chart
    window.visitorChart = new Chart(canvas, config);
}

// Smooth scrolling for navigation links
document.addEventListener('click', function(e) {
    if (e.target.classList.contains('nav-link')) {
        e.preventDefault();
        const targetId = e.target.getAttribute('href');
        const targetElement = document.querySelector(targetId);
        
        if (targetElement) {
            const offsetTop = targetElement.offsetTop - 80; // Account for fixed navbar
            window.scrollTo({
                top: offsetTop,
                behavior: 'smooth'
            });
        }
    }
});

// Hash change listener for admin mode
window.addEventListener('hashchange', function() {
    if (location.hash === '#admin') {
        showAnalytics();
    }
});

// Add some interactive effects
document.addEventListener('DOMContentLoaded', function() {
    // Add hover effects for skill tags
    const skills = document.querySelectorAll('.skill');
    skills.forEach(skill => {
        skill.addEventListener('mouseenter', function() {
            this.style.transform = 'translateY(-2px) scale(1.05)';
        });
        
        skill.addEventListener('mouseleave', function() {
            this.style.transform = 'translateY(0) scale(1)';
        });
    });
    
    // Add parallax effect to hero section
    const heroSection = document.querySelector('.hero-section');
    if (heroSection) {
        window.addEventListener('scroll', function() {
            const scrolled = window.pageYOffset;
            const rate = scrolled * -0.5;
            heroSection.style.transform = `translateY(${rate}px)`;
        });
    }
});