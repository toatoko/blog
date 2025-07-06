import { Controller } from "@hotwired/stimulus"
import { createPopup } from "@picmo/popup-picker"

export class RichText {
  constructor(picker, emojiButton) {
    this.picker = picker;
    this.emojiButton = emojiButton;
    this.createEmojiPickerButton();
  }

  createEmojiPickerButton() {
    this.emojiButton.addEventListener('click', this.toggleEmojiPicker.bind(this));
    const blockToolsGroup = document.querySelector("[data-trix-button-group=block-tools]");
    if (blockToolsGroup) {
      blockToolsGroup.prepend(this.emojiButton);
    }
  }

  toggleEmojiPicker(event) {
    if (this.picker) {
      this.picker.toggle();
    }
  }

  setPicker(picker) {
    this.picker = picker;
  }
}

export default class extends Controller {
  // Remove static targets - we'll use querySelector instead

  connect() {


    // Prevent multiple instances from initializing
    if (this.element.dataset.emojiPickerInitialized) {

      return;
    }

    // Mark as initialized
    this.element.dataset.emojiPickerInitialized = "true";

    // Wait for Trix editor to be fully initialized
    const checkAndInitialize = () => {
      const pickerContainer = this.element.querySelector('[data-emoji-picker-target="pickerContainer"]');
      const trixEditor = this.element.querySelector('[data-emoji-picker-target="trixEditor"]');

      if (pickerContainer && trixEditor && trixEditor.editor) {

        this.initializeEmojiPicker();
      } else {

        setTimeout(checkAndInitialize, 200);
      }
    };

    checkAndInitialize();
  }

  initializeEmojiPicker() {
    try {
      const pickerContainer = this.element.querySelector('[data-emoji-picker-target="pickerContainer"]');
      const trixEditor = this.element.querySelector('[data-emoji-picker-target="trixEditor"]');

      // Check if button already exists
      const existingButton = document.querySelector('#emoji-picker');
      if (existingButton) {

        existingButton.remove();
      }

      const buttonString = this.emojiButtonString();
      const emojiButton = this.emojiButtonTemplate(buttonString);
      let picker;
      let richText = new RichText(picker, emojiButton);

      picker = createPopup({
        // Use document.body instead of pickerContainer
        rootElement: document.body,
        zIndex: 99999,
        className: 'emoji-picker-popup'
      }, {
        triggerElement: emojiButton,
        referenceElement: emojiButton,
        position: "bottom-start",
      });

      picker.addEventListener("emoji:select", (event) => {
        trixEditor.editor.insertString(event.emoji);
      });

      richText.setPicker(picker);

    } catch (error) {

    }
  }

  emojiButtonTemplate(buttonString) {
    const domParser = new DOMParser();
    const emojiButton = domParser
      .parseFromString(buttonString, "text/html")
      .querySelector("button");
    return emojiButton;
  }

  emojiButtonString() {
    const buttonString = `<button class="trix-button" id="emoji-picker" data-trix-action="popupPicker" tabindex="1">😀</button>`;
    return buttonString;
  }
}