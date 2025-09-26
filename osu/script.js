
// دالة للانتقال إلى صفحة التسجيل
function startSignup() {
    window.location.href = 'signup.html';
}

// دالة للعودة إلى الصفحة الرئيسية
function goBack() {
    window.location.href = 'index.html';
}

// دالة لعرض شروط الاستخدام
function showTerms() {
    alert(`شروط الاستخدام:
    
1. هذه الخدمة مقدمة مجاناً لزوار المتجر
2. يمنع استخدام الشبكة لأغراض غير قانونية
3. يحق للإدارة إيقاف الخدمة في أي وقت
4. البيانات الشخصية محمية ولا تباع لأطراف ثالثة

شكراً لاستخدامك خدمتنا!`);
}

// معالجة نموذج التسجيل
document.addEventListener('DOMContentLoaded', function() {
    const signupForm = document.getElementById('signup-form');
    
    if (signupForm) {
        signupForm.addEventListener('submit', function(e) {
            e.preventDefault();
            
            // جمع البيانات من النموذج
            const formData = {
                name: document.getElementById('name').value,
                email: document.getElementById('email').value,
                phone: document.getElementById('phone').value,
                timestamp: new Date().toISOString()
            };
            
            // محاكاة إرسال البيانات إلى الخادم
            console.log('بيانات التسجيل:', formData);
            
            // هنا يمكنك إضافة كود إرسال البيانات إلى الخادم
            // await fetch('/api/signup', { method: 'POST', body: JSON.stringify(formData) });
            
            // الانتقال إلى صفحة النجاح
            window.location.href = 'success.html';
        });
    }
});
function addPageEffects() {
    const cards = document.querySelectorAll('.feature-card');
    cards.forEach((card, index) => {
        card.style.animationDelay = `${index * 0.2}s`;
        card.classList.add('fade-in');
    });
}
document.addEventListener('DOMContentLoaded', function() {
    addPageEffects();
    const buttons = document.querySelectorAll('button');
    buttons.forEach(button => {
        button.addEventListener('mouseenter', function() {
            this.style.transform = 'scale(1.05)';
        });
        
        button.addEventListener('mouseleave', function() {
            this.style.transform = 'scale(1)';
        });
    });
});

// إضافة أنيميشن للبطاقات
const style = document.createElement('style');
style.textContent = `
    .fade-in {
        animation: fadeIn 0.6s ease-in-out forwards;
        opacity: 0;
    }
    
    @keyframes fadeIn {
        from {
            opacity: 0;
            transform: translateY(20px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }
`;
document.head.appendChild(style);