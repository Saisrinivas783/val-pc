const yesBtn = document.getElementById('yesBtn');
const noBtn = document.getElementById('noBtn');
const questionContent = document.getElementById('questionContent');
const successMessage = document.getElementById('successMessage');

// Handle Yes button click
yesBtn.addEventListener('click', () => {
    questionContent.classList.add('hidden');
    successMessage.classList.remove('hidden');

    // Add confetti effect
    createConfetti();
});

// Handle No button - make it move away from cursor smoothly
let currentX = 0;
let currentY = 0;

document.addEventListener('mousemove', (e) => {
    const buttonRect = noBtn.getBoundingClientRect();
    const buttonCenterX = buttonRect.left + buttonRect.width / 2;
    const buttonCenterY = buttonRect.top + buttonRect.height / 2;

    const mouseX = e.clientX;
    const mouseY = e.clientY;

    // Calculate distance between mouse and button center
    const distance = Math.sqrt(
        Math.pow(mouseX - buttonCenterX, 2) + Math.pow(mouseY - buttonCenterY, 2)
    );

    // If mouse gets too close (within 150px), move the button away
    if (distance < 150) {
        moveButtonAway(mouseX, mouseY, buttonCenterX, buttonCenterY);
    }
});

noBtn.addEventListener('click', (e) => {
    e.preventDefault();
    moveButtonAway(e.clientX, e.clientY, 0, 0);
});

function moveButtonAway(mouseX, mouseY, buttonX, buttonY) {
    // Calculate direction away from mouse
    const deltaX = buttonX - mouseX;
    const deltaY = buttonY - mouseY;

    // Normalize and add some randomness
    const angle = Math.atan2(deltaY, deltaX);
    const moveDistance = 150 + Math.random() * 100;

    currentX += Math.cos(angle) * moveDistance;
    currentY += Math.sin(angle) * moveDistance;

    // Keep button within reasonable bounds
    const maxDistance = 300;
    currentX = Math.max(-maxDistance, Math.min(maxDistance, currentX));
    currentY = Math.max(-maxDistance, Math.min(maxDistance, currentY));

    // Apply smooth transform
    noBtn.style.transform = `translate(${currentX}px, ${currentY}px)`;
}

// Confetti effect
function createConfetti() {
    const colors = ['#ff1493', '#ff69b4', '#ffb6c1', '#ff1493', '#ff69b4'];

    for (let i = 0; i < 50; i++) {
        setTimeout(() => {
            const confetti = document.createElement('div');
            confetti.style.position = 'fixed';
            confetti.style.left = Math.random() * window.innerWidth + 'px';
            confetti.style.top = '-10px';
            confetti.style.width = '10px';
            confetti.style.height = '10px';
            confetti.style.backgroundColor = colors[Math.floor(Math.random() * colors.length)];
            confetti.style.borderRadius = '50%';
            confetti.style.pointerEvents = 'none';
            confetti.style.zIndex = '1000';

            document.body.appendChild(confetti);

            const duration = 2000 + Math.random() * 2000;
            const targetY = window.innerHeight + 10;
            const targetX = parseFloat(confetti.style.left) + (Math.random() - 0.5) * 200;

            confetti.animate([
                { transform: 'translateY(0px) translateX(0px) rotate(0deg)', opacity: 1 },
                { transform: `translateY(${targetY}px) translateX(${targetX - parseFloat(confetti.style.left)}px) rotate(${Math.random() * 360}deg)`, opacity: 0 }
            ], {
                duration: duration,
                easing: 'cubic-bezier(0.25, 0.46, 0.45, 0.94)'
            });

            setTimeout(() => {
                confetti.remove();
            }, duration);
        }, i * 30);
    }
}
