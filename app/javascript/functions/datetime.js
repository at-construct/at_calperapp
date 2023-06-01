import { format, addHours, isWithinInterval, closestTo } from 'date-fns';
import { ja } from 'date-fns/locale';

export const getTimeIntervalList = () => {
  // 15分間隔の時間のリストを返す
  const hours = [...Array(24)].map((_, i) => ('0' + i).slice(-2));
  const minutes = ['00', '15', '30', '45'];
  const timeList = hours
    .map(hour => minutes.map(minute => hour + ':' + minute))
    .flat();

  // 現在時刻を取得し、タイムリストの中で最も近い時間を見つける
  const currentTime = format(new Date(), 'HH:mm');
  const closestTime = closestTo(new Date(`${format(new Date(),
  'yyyy/MM/dd')} ${currentTime}`),
  timeList.map(time => new Date(`${format(new Date(),
  'yyyy/MM/dd')} ${time}`)));

  // タイムリストを現在時刻からスライスして、最初の要素を現在時刻に設定する
  const index = timeList.indexOf(format(closestTime, 'HH:mm'));
  const start = timeList.slice(index);
  const end = timeList.slice(0, index);
  return [...start, ...end];
};

export const getDefaultStartAndEnd = date => {
  // デフォルトの開始時刻と終了時刻を返す
  const currentTime = format(new Date(), 'HH:mm:ss');
  const datetime = new Date(`${date} ${currentTime}`);
  const start = format(addHours(datetime, 1), 'yyyy/MM/dd HH:00:00');
  const end = format(addHours(datetime, 2), 'yyyy/MM/dd HH:00:00');
  return [start, end];
};

export const isGreaterEndThanStart = (
  startDate,
  startTime,
  endDate,
  endTime,
  allDay
) => {
  // 終了日時が開始日時の後になっているか
  if (allDay) {
    const start = new Date(startDate).getTime();
    const end = new Date(endDate).getTime();
    return end >= start;
  } else {
    const start = new Date(`${startDate} ${startTime}`).getTime();
    const end = new Date(`${endDate} ${endTime}`).getTime();
    return end > start;
  }
};

export const formatDateToJa = date => {
  // 日付を日本語表記で返す
  return format(new Date(date), 'M月d日(E)', { locale: ja });
};

export const isDateWithinInterval = (date, startDate, endDate) => {
  // startDateとendDateの間にdateが含まれるかどうか
  return isWithinInterval(new Date(date), {
    start: new Date(startDate),
    end: new Date(endDate)
  });
};

export const compareDates = (a, b) => {
  // 日付の比較を行う
  if (a.start < b.start) return -1;
  if (a.start > b.start) return 1;
  return 0;
};
