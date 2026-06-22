import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="autosubmit"
export default class extends Controller {
  submit(event) {
    const form = event.currentTarget.form;

    if (!form) return;

    try {
      form.requestSubmit();
    } catch (error) {
      console.error("Autosubmit: Erreur lors de la soumission:", error);
    }
  }
}
