// JavaScript for AWS CloudFront + S3 CDN Demo
document.addEventListener('DOMContentLoaded', function() {
    console.log('🚀 AWS CloudFront + S3 CDN Demo loaded successfully!');
    
    // Add some interactive features
    addPerformanceMetrics();
    addInteractiveElements();
});

function addPerformanceMetrics() {
    // Display page load performance
    window.addEventListener('load', function() {
        const loadTime = performance.timing.loadEventEnd - performance.timing.navigationStart;
        console.log(`Page loaded in ${loadTime}ms`);
        
        // Add performance info to the page
        const performanceInfo = document.createElement('div');
        performanceInfo.style.cssText = `
            position: fixed;
            bottom: 20px;
            right: 20px;
            background: rgba(0,0,0,0.8);
            color: white;
            padding: 10px 15px;
            border-radius: 5px;
            font-size: 12px;
            z-index: 1000;
        `;
        performanceInfo.textContent = `Load time: ${loadTime}ms`;
        document.body.appendChild(performanceInfo);
        
        // Remove after 5 seconds
        setTimeout(() => {
            performanceInfo.remove();
        }, 5000);
    });
}

function addInteractiveElements() {
    // Add click effects to feature cards
    const featureCards = document.querySelectorAll('.feature-card');
    
    featureCards.forEach(card => {
        card.addEventListener('click', function() {
            // Add a subtle click effect
            this.style.transform = 'scale(0.98)';
            setTimeout(() => {
                this.style.transform = '';
            }, 150);
        });
        
        // Add hover sound effect (optional)
        card.addEventListener('mouseenter', function() {
            this.style.cursor = 'pointer';
        });
    });
    
    // Add a simple counter animation
    const counters = document.querySelectorAll('.feature-card h3');
    counters.forEach(counter => {
        const text = counter.textContent;
        if (text.includes('🌍')) {
            animateCounter(counter, 'Global Distribution', 0, 200, 2000);
        } else if (text.includes('🔒')) {
            animateCounter(counter, 'Security', 0, 100, 2000);
        } else if (text.includes('⚡')) {
            animateCounter(counter, 'Performance', 0, 150, 2000);
        } else if (text.includes('📊')) {
            animateCounter(counter, 'Monitoring', 0, 120, 2000);
        }
    });
}

function animateCounter(element, prefix, start, end, duration) {
    let startTime = null;
    
    function animate(currentTime) {
        if (!startTime) startTime = currentTime;
        const progress = Math.min((currentTime - startTime) / duration, 1);
        const current = Math.floor(progress * (end - start) + start);
        
        element.textContent = `${prefix} (${current}%)`;
        
        if (progress < 1) {
            requestAnimationFrame(animate);
        } else {
            // Reset to original text
            setTimeout(() => {
                element.textContent = prefix;
            }, 1000);
        }
    }
    
    requestAnimationFrame(animate);
}

// Add a simple service worker simulation
if ('serviceWorker' in navigator) {
    console.log('Service Worker supported - would register here in a real app');
}

// Add some fun easter eggs
document.addEventListener('keydown', function(e) {
    if (e.ctrlKey && e.key === 'c') {
        console.log('🎉 You found an easter egg! This site is powered by AWS CloudFront + S3 CDN');
    }
});

// Add smooth scrolling for any anchor links
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