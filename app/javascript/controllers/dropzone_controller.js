import { Controller } from "@hotwired/stimulus";
import { DirectUpload } from "@rails/activestorage";
import Dropzone from "dropzone";

export function getMetaValue(name) {
  const element = findElement(document.head, `meta[name="${name}"]`);
  if (element) {
    return element.getAttribute("content");
  }
}

export function findElement(root, selector) {
  if (typeof root == "string") {
    selector = root;
    root = document;
  }
  return root.querySelector(selector);
}

export function removeElement(el) {
  if (el && el.parentNode) {
    el.parentNode.removeChild(el);
  }
}

export function insertAfter(el, referenceNode) {
  return referenceNode.parentNode.insertBefore(el, referenceNode.nextSibling);
}

export default class extends Controller {
  static targets = ["input"];

  connect() {
    this.dropzone = createDropZone(this);
    this.hideFileInput();
    this.bindEvents();
    this.addExistingFiles();
    Dropzone.autoDiscover = false;
  }

  addExistingFiles() {
    // Check if there are existing files to display
    const existingFiles = this.data.get("existingFiles");
    if (existingFiles) {
      const files = JSON.parse(existingFiles);
      files.forEach(fileData => {
        const mockFile = {
          name: fileData.name,
          size: fileData.size,
          accepted: true,
          existing: true
        };

        this.dropzone.emit("addedfile", mockFile);
        this.dropzone.emit("thumbnail", mockFile, fileData.url);
        this.dropzone.emit("complete", mockFile);
      });
    }
  }

  hideFileInput() {
    this.inputTarget.style.display = "none";
    this.inputTarget.disabled = true;
  }

  bindEvents() {
    this.dropzone.on("addedfile", (file) => {
      console.log("File added:", file.name);
      setTimeout(() => {
        if (file.accepted) {
          createDirectUploadController(this, file).start();
        }
      }, 500);
    });

    this.dropzone.on("removedfile", (file) => {
      console.log("File removed:", file.name);
      if (file.controller) {
        removeElement(file.controller.hiddenInput);
      }
    });

    this.dropzone.on("canceled", (file) => {
      console.log("File canceled:", file.name);
      if (file.controller) {
        file.controller.xhr.abort();
      }
    });

    this.dropzone.on("processing", (file) => {
      console.log("Processing file:", file.name);
      if (this.submitButton) {
        this.submitButton.disabled = true;
      }
    });

    this.dropzone.on("queuecomplete", () => {
      console.log("Queue complete");
      if (this.submitButton) {
        this.submitButton.disabled = false;
      }
    });

    this.dropzone.on("success", (file) => {
      console.log("File upload success:", file.name);
    });

    this.dropzone.on("error", (file, error) => {
      console.error("File upload error:", file.name, error);
    });
  }

  get headers() {
    return { "X-CSRF-Token": getMetaValue("csrf-token") };
  }
  get url() {
    return this.inputTarget.getAttribute("data-direct-upload-url");
  }
  get maxFiles() {
    return this.data.get("maxFiles") || 2;
  }
  get maxFilesize() {
    return this.data.get("maxFileSize") || 256;
  }
  get acceptedFiles() {
    return this.data.get("acceptedFiles");
  }
  get addRemoveLinks() {
    return this.data.get("addRemoveLinks") || true;
  }
  get uploadMultiple() {
    return this.data.get("uploadMultiple") || true;
  }
  get form() {
    return this.element.closest("form");
  }
  get submitButton() {
    return findElement(this.form, "input[type=submit], button[type=submit]");
  }
}

class DirectUploadController {
  constructor(source, file) {
    this.directUpload = createDirectUpload(file, source.url, this);
    this.source = source;
    this.file = file;
  }

  start() {
    this.file.controller = this;
    this.hiddenInput = this.createHiddenInput();
    console.log("Starting direct upload for:", this.file.name);

    this.directUpload.create((error, attributes) => {
      if (error) {
        console.error("Direct upload error:", error);
        removeElement(this.hiddenInput);
        this.emitDropzoneError(error);
      } else {
        console.log("Direct upload success, signed_id:", attributes.signed_id);
        this.hiddenInput.value = attributes.signed_id;
        this.emitDropzoneSuccess();
      }
    });
  }

  createHiddenInput() {
    const input = document.createElement("input");
    input.type = "hidden";
    input.name = this.source.inputTarget.name;
    insertAfter(input, this.source.inputTarget);
    return input;
  }

  directUploadWillStoreFileWithXHR(xhr) {
    this.bindProgressEvent(xhr);
    this.emitDropzoneUploading();
  }

  bindProgressEvent(xhr) {
    this.xhr = xhr;
    this.xhr.upload.addEventListener("progress", (event) =>
      this.uploadRequestDidProgress(event));
  }

  uploadRequestDidProgress(event) {
    const element = this.source.element
    const progress = (event.loaded / event.total) * 100;
    findElement(
      this.file.previewTemplate,
      ".dz-upload"
    ).style.width = `${progress}%`;
  }

  emitDropzoneUploading() {
    this.file.status = Dropzone.UPLOADING;
    this.source.dropzone.emit("processing", this.file);
  }

  emitDropzoneError(error) {
    this.file.status = Dropzone.ERROR;
    this.source.dropzone.emit("error", this.file, error);
    this.source.dropzone.emit("complete", this.file);
  }

  emitDropzoneSuccess() {
    this.file.status = Dropzone.SUCCESS;
    this.source.dropzone.emit("success", this.file);
    this.source.dropzone.emit("complete", this.file);
  }
}

function createDirectUploadController(source, file) {
  return new DirectUploadController(source, file);
}

function createDirectUpload(file, url, controller) {
  return new DirectUpload(file, url, controller);
}

function createDropZone(controller) {
  let dropzone = new Dropzone(controller.element, {
    url: controller.url,
    headers: controller.headers,
    maxFiles: controller.maxFiles,
    maxFilesize: controller.maxFilesize,
    acceptedFiles: controller.acceptedFiles,
    addRemoveLinks: controller.addRemoveLinks,
    uploadMultiple: controller.uploadMultiple,
    autoQueue: false,
  });
  return dropzone;
}