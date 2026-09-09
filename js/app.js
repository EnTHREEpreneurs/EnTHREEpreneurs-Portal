document.addEventListener("DOMContentLoaded", () => {
  const data = window.ENTHREE_DATA || { subjects: [], transactions: [] };

  const menuToggle = document.getElementById("menuToggle");
  const mainNav = document.getElementById("mainNav");
  if (menuToggle && mainNav) {
    menuToggle.addEventListener("click", () => {
      const open = mainNav.classList.toggle("open");
      menuToggle.setAttribute("aria-expanded", String(open));
    });
    mainNav.querySelectorAll("a").forEach(a => a.addEventListener("click", () => {
      mainNav.classList.remove("open");
      menuToggle.setAttribute("aria-expanded", "false");
    }));
  }

  const today = new Date();
  const dateEl = document.getElementById("todayDate");
  if (dateEl) dateEl.textContent = today.toLocaleDateString("en-PH", {month:"short", day:"numeric", year:"numeric"});
  const yearEl = document.getElementById("year");
  if (yearEl) yearEl.textContent = today.getFullYear();

  const subjectCount = document.getElementById("subjectCount");
  if (subjectCount) subjectCount.textContent = `${data.subjects.length} Subjects`;

  const makeSubjects = (targetId, type) => {
    const target = document.getElementById(targetId);
    if (!target) return;
    target.innerHTML = data.subjects.map((s, i) => `
      <article class="subject-card">
        <div class="subject-icon">${s.icon}</div>
        <h3>${s.name}</h3>
        <p>${s.description}</p>
        <a href="pages/subject.html?subject=${encodeURIComponent(s.name)}&type=${type}">Open subject →</a>
      </article>
    `).join("");
  };
  makeSubjects("resourceSubjects", "resources");
  makeSubjects("activitySubjects", "activities");

  const fundTable = document.getElementById("fundTable");
  const fundBalance = document.getElementById("fundBalance");
  if (fundTable && fundBalance) {
    let balance = 0;
    if (!data.transactions.length) {
      fundTable.innerHTML = `<tr><td colspan="5">No transactions have been added yet.</td></tr>`;
    } else {
      fundTable.innerHTML = data.transactions.map(t => {
        balance += (t.income || 0) - (t.expense || 0);
        return `<tr><td>${t.date}</td><td>${t.description}</td><td>${t.income ? "₱"+t.income.toFixed(2) : "—"}</td><td>${t.expense ? "₱"+t.expense.toFixed(2) : "—"}</td><td>₱${balance.toFixed(2)}</td></tr>`;
      }).join("");
    }
    fundBalance.textContent = "₱" + balance.toLocaleString("en-PH", {minimumFractionDigits:2});
  }
});
