const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransport({
  host:   process.env.EMAIL_HOST  || 'smtp.gmail.com',
  port:   parseInt(process.env.EMAIL_PORT) || 587,
  secure: false,
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

/**
 * Send login credentials to a newly created habitant.
 */
const sendCredentials = async ({ to, nom, prenom, email, password, immeubleNom }) => {
  if (!process.env.EMAIL_USER) {
    console.log(`[EmailService] Skipped (no EMAIL_USER configured). Credentials for ${email}: ${password}`);
    return;
  }
  await transporter.sendMail({
    from: `"Syndic App" <${process.env.EMAIL_FROM || process.env.EMAIL_USER}>`,
    to,
    subject: 'Vos identifiants de connexion — Syndic App',
    html: `
      <h2>Bienvenue, ${prenom} ${nom} !</h2>
      <p>Votre compte pour la résidence <strong>${immeubleNom}</strong> a été créé.</p>
      <table>
        <tr><td><strong>Email :</strong></td><td>${email}</td></tr>
        <tr><td><strong>Mot de passe :</strong></td><td>${password}</td></tr>
      </table>
      <p>Veuillez changer votre mot de passe après la première connexion.</p>
    `,
  });
};

/**
 * Send a payment reminder to an habitant who hasn't paid.
 */
const sendPaymentReminder = async ({ to, nom, prenom, chargeNom, montantDu, dateEcheance }) => {
  if (!process.env.EMAIL_USER) return;
  await transporter.sendMail({
    from: `"Syndic App" <${process.env.EMAIL_FROM || process.env.EMAIL_USER}>`,
    to,
    subject: `Rappel de paiement — ${chargeNom}`,
    html: `
      <h2>Rappel de paiement</h2>
      <p>Bonjour ${prenom} ${nom},</p>
      <p>Vous avez un paiement en attente :</p>
      <ul>
        <li><strong>Charge :</strong> ${chargeNom}</li>
        <li><strong>Montant dû :</strong> ${montantDu} MAD</li>
        <li><strong>Échéance :</strong> ${dateEcheance}</li>
      </ul>
      <p>Merci de régulariser votre situation.</p>
    `,
  });
};

/**
 * Send a payment confirmation to an habitant who fully paid.
 */
const sendPaymentConfirmation = async ({ to, nom, prenom, chargeNom, montant }) => {
  if (!process.env.EMAIL_USER) return;
  await transporter.sendMail({
    from: `"Syndic App" <${process.env.EMAIL_FROM || process.env.EMAIL_USER}>`,
    to,
    subject: `Paiement confirmé — ${chargeNom}`,
    html: `
      <h2>Paiement confirmé ✅</h2>
      <p>Bonjour ${prenom} ${nom},</p>
      <p>Votre paiement de <strong>${montant} MAD</strong> pour la charge <strong>${chargeNom}</strong> a bien été enregistré.</p>
      <p>Merci !</p>
    `,
  });
};

module.exports = { sendCredentials, sendPaymentReminder, sendPaymentConfirmation };
