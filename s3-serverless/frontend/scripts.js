// Backend URL - this variable will be replaced with the actual backend URL
var backend_url = "${backend_api_url}";

// Section highlight in nav (if nav exists)
document.addEventListener('DOMContentLoaded', function() {
    // Highlight current section in view
    if (window.IntersectionObserver) {
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    document.querySelectorAll('nav a').forEach(link => {
                        link.classList.remove('active');
                        if (link.getAttribute('href') === `#${entry.target.id}`) {
                            link.classList.add('active');
                        }
                    });
                }
            });
        }, {threshold: 0.7});
        document.querySelectorAll('section').forEach(section => {
            observer.observe(section);
        });
    }

    // Project view buttons (if any)
    document.querySelectorAll('.view-project').forEach(button => {
        button.addEventListener('click', function() {
            const project = this.parentElement;
            alert(`Opening project: ${project.querySelector('h3').textContent}`);
        });
    });

    // PDF export stub (if button exists)
    if (document.getElementById('exportPDF')) {
        document.getElementById('exportPDF').addEventListener('click', function() {
            alert('PDF export functionality would be implemented here');
        });
    }

    updateVisitorCount();
});

// Update visitor count
async function updateVisitorCount() {
    try {
        const apiUrl = backend_url + '/visitor';
        const response = await fetch(apiUrl);
        const data = await response.json();
        document.getElementById('visitorCount').textContent = data.count;
    } catch (error) {
        console.error('Error fetching visitor count:', error);
        document.getElementById('visitorCount').textContent = 'Error';
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
        try {
            const response = await fetch(backend_url + '/contact', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(formData)
            });
            const result = await response.json();
            document.getElementById('formStatus').textContent = 
                response.ok ? 'Message sent successfully!' : `Error: $${result.error}`;
            document.getElementById('formStatus').style.color = response.ok ? 'green' : 'red';
            if (response.ok) {
                document.getElementById('contactForm').reset();
                setTimeout(() => {
                    document.getElementById('formStatus').textContent = '';
                }, 3000);
            }
        } catch (error) {
            document.getElementById('formStatus').textContent = 'Error sending message.';
            document.getElementById('formStatus').style.color = 'red';
            console.error('Error:', error);
        }
    });
}
