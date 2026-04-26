const modulos = [
  "Fundação do Consultório",
  "Captação e Retenção",
  "Excelência Clínica",
  "Gestão e Indicadores",
  "Escala Sustentável"
];

const progresso = new Set();
const badgeCatalog = {
  2: "Iniciante Estratégico",
  4: "Gestor de Consultório",
  5: "Psiquiatra de Alta Performance"
};

const certificados = new Map([
  ["PPC-2026-AB12", "Certificado válido para Aluna Demo"],
  ["PPC-2026-ZX98", "Certificado válido para Aluno Demo"]
]);

const dashboard = document.querySelector("#dashboard");
const modulosList = document.querySelector("#modulosList");
const progressBar = document.querySelector("#progressBar");
const progressLabel = document.querySelector("#progressLabel");
const pointsNode = document.querySelector("#points");
const badgesList = document.querySelector("#badgesList");
const quizDialog = document.querySelector("#quizDialog");
const quizForm = document.querySelector("#quizForm");
const gerarCertificadoBtn = document.querySelector("#gerarCertificadoBtn");
const certificadoCode = document.querySelector("#certificadoCode");

const forumPosts = document.querySelector("#forumPosts");
const forumForm = document.querySelector("#forumForm");

let points = 0;

function renderModulos() {
  modulosList.innerHTML = "";
  modulos.forEach((modulo, index) => {
    const li = document.createElement("li");
    const checked = progresso.has(index);

    li.innerHTML = `<span>${modulo}</span>`;

    const checkbox = document.createElement("input");
    checkbox.type = "checkbox";
    checkbox.checked = checked;
    checkbox.addEventListener("change", () => {
      if (checkbox.checked) {
        progresso.add(index);
      } else {
        progresso.delete(index);
      }
      atualizarProgresso();
      renderModulos();
    });

    li.appendChild(checkbox);
    modulosList.appendChild(li);
  });
}

function atualizarProgresso() {
  const ratio = Math.round((progresso.size / modulos.length) * 100);
  progressBar.style.width = `${ratio}%`;
  progressLabel.textContent = `Progresso: ${ratio}%`;

  badgesList.innerHTML = "";
  Object.entries(badgeCatalog).forEach(([threshold, name]) => {
    if (progresso.size >= Number(threshold)) {
      const badge = document.createElement("li");
      badge.textContent = `🏅 ${name}`;
      badgesList.appendChild(badge);
    }
  });

  gerarCertificadoBtn.disabled = progresso.size !== modulos.length;
}

function abrirDashboard() {
  dashboard.classList.remove("hidden");
  dashboard.scrollIntoView({ behavior: "smooth" });
}

document.querySelector("#ctaMentoria").addEventListener("click", () => {
  document.querySelector("#mentoria").scrollIntoView({ behavior: "smooth" });
});

document.querySelector("#ctaDashboard").addEventListener("click", abrirDashboard);
document.querySelector("#entrarBtn").addEventListener("click", abrirDashboard);
document.querySelector("#quizBtn").addEventListener("click", () => quizDialog.showModal());

document.querySelector("#submitQuiz").addEventListener("click", (event) => {
  event.preventDefault();
  const data = new FormData(quizForm);
  const score = Number(data.get("q1")) + Number(data.get("q2"));
  points += score * 50;
  pointsNode.textContent = String(points);
  quizDialog.close();
});

gerarCertificadoBtn.addEventListener("click", () => {
  const code = `PPC-2026-${Math.random().toString(36).slice(2, 6).toUpperCase()}`;
  certificados.set(code, "Certificado válido para aluno(a) da plataforma");
  certificadoCode.textContent = `Seu certificado: ${code}`;
});

forumForm.addEventListener("submit", (event) => {
  event.preventDefault();
  const autor = document.querySelector("#postAutor").value.trim();
  const titulo = document.querySelector("#postTitulo").value.trim();
  const conteudo = document.querySelector("#postConteudo").value.trim();

  const li = document.createElement("li");
  li.innerHTML = `<strong>${titulo}</strong><p>${conteudo}</p><small>por ${autor}</small>`;
  forumPosts.prepend(li);
  forumForm.reset();
});

document.querySelector("#verifyBtn").addEventListener("click", () => {
  const code = document.querySelector("#verifyInput").value.trim().toUpperCase();
  const result = document.querySelector("#verifyResult");
  const value = certificados.get(code);
  result.textContent = value ?? "Código não encontrado.";
});

renderModulos();
atualizarProgresso();

const seedPost = document.createElement("li");
seedPost.innerHTML =
  "<strong>Como reduzir no-show no consultório?</strong><p>Quais fluxos vocês usam para confirmação de agenda?</p><small>por Dra. Marina</small>";
forumPosts.appendChild(seedPost);
