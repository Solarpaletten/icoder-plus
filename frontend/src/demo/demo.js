// 🚀 iCoder Plus JavaScript Demo
// This file demonstrates JavaScript execution in the live preview

console.log('🎉 Welcome to iCoder Plus Live Preview!');

// Basic calculations
const numbers = [1, 2, 3, 4, 5];
const sum = numbers.reduce((a, b) => a + b, 0);
const average = sum / numbers.length;

console.log('📊 Array:', numbers);
console.log('➕ Sum:', sum);
console.log('📈 Average:', average);

// Object manipulation
const user = {
    name: 'Developer',
    age: 25,
    skills: ['JavaScript', 'React', 'Node.js']
};

console.log('👤 User Info:', user);
console.log('🔧 Skills:', user.skills.join(', '));

// Function demonstration
function fibonacci(n) {
    if (n <= 1) return n;
    return fibonacci(n - 1) + fibonacci(n - 2);
}

const fibSequence = [];
for (let i = 0; i < 10; i++) {
    fibSequence.push(fibonacci(i));
}

console.log('🔢 Fibonacci Sequence:', fibSequence);

// Promise demonstration
function simulateAsyncWork() {
    return new Promise((resolve) => {
        setTimeout(() => {
            resolve('✅ Async work completed!');
        }, 1000);
    });
}

simulateAsyncWork().then(result => {
    console.log('⏰', result);
});

// Error handling demonstration
try {
    throw new Error('This is a demo error');
} catch (error) {
    console.error('❌ Caught error:', error.message);
}

console.log('🏁 JavaScript demo execution completed!');
