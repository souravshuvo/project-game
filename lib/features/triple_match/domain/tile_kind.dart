enum TileKind {
  jarLabel('Jar', 'JAR'),
  foldedNote('Note', 'NOTE'),
  berryTin('Tin', 'TIN'),
  flourTag('Flour', 'FLR'),
  teaPacket('Tea', 'TEA'),
  seedCard('Seed', 'SEED'),
  honeyMark('Honey', 'HNY'),
  ribbonTab('Ribbon', 'RIB'),
  oatStamp('Oat', 'OAT'),
  cocoaSeal('Cocoa', 'COA');

  const TileKind(this.displayName, this.shortLabel);

  final String displayName;
  final String shortLabel;
}
