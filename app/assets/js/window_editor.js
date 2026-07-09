import Alpine from "alpinejs";

const DAYS = ["sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"];

const toMinutes = value => {
  const [hours, minutes] = String(value).split(":").map(Number);
  return hours * 60 + minutes;
};

const matches = (slot, minutes) => {
  const start = toMinutes(slot.start);
  const stop = toMinutes(slot.end);

  if (Number.isNaN(start) || Number.isNaN(stop)) return false;

  return stop <= start ? minutes >= start || minutes < stop : minutes >= start && minutes < stop;
};

document.addEventListener("alpine:init", () => {
  Alpine.data("windowEditor", () => ({
    days: DAYS,
    windows: [],

    init() {
      const value = this.$refs.field.value;
      const parsed = value ? JSON.parse(value) : null;

      this.windows = parsed || [{days: [...DAYS], start: "00:00", end: "00:00"}];
      this.sync();
    },

    sync() { this.$refs.field.value = JSON.stringify(this.windows); },

    covered(day, hour) {
      const minutes = hour * 60 + 30;
      return this.windows.some(slot => slot.days.includes(day) && matches(slot, minutes));
    },

    toggle(slot, day) {
      slot.days.includes(day) ? slot.days = slot.days.filter(it => it != day) : slot.days.push(day);
      this.sync();
    },

    add() {
      this.windows.push({days: DAYS.slice(1, 6), start: "08:00", end: "18:00"});
      this.sync();
    },

    always() {
      this.windows = [{days: [...DAYS], start: "00:00", end: "00:00"}];
      this.sync();
    },

    never() {
      this.windows = [];
      this.sync();
    },

    remove(index) {
      this.windows.splice(index, 1);
      this.sync();
    }
  }));
});
