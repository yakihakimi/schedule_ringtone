// Rules applied
export interface AudioFile {
  id: string;
  name: string;
  url: string;
  duration: number;
  file: File;
  type: 'original' | 'ringtone';
  startTime?: number;
  endTime?: number;
}

export interface RingtoneSettings {
  startTime: number;
  endTime: number;
  fadeIn: number;
  fadeOut: number;
  volume: number;
}

export interface PlaybackState {
  isPlaying: boolean;
  currentTime: number;
  duration: number;
  volume: number;
}
