package bidirectionalsyncviarsync

import (
	"encoding/base32"
	"encoding/json"
	"os"
	"path/filepath"
	"strings"

	"lukechampine.com/blake3"
)

type SyncConfig struct {
	leftRoot    string
	rightRoot   string
	stateDbPath string
}

type SyncState struct {
	leftFiles  map[string]os.FileInfo
	rightFiles map[string]os.FileInfo
}

type Sync struct {
	conf        SyncConfig
	current     SyncState
	prev        SyncState
	listingDone chan struct{}
}

func checkError(err error) {
	if err != nil {
		panic(err)
	}
}

func filepathStem(path string) string {
	// Get the base name of the file without the extension
	base := filepath.Base(path)
	ext := filepath.Ext(base)
	return base[:len(base)-len(ext)]
}

func stringHashBase32(s string) string {
	hash := blake3.New(8, nil)
	hash.Write([]byte(s))
	return base32.StdEncoding.EncodeToString(hash.Sum(nil))
}

func (s *Sync) LoadConfig(cfg_path string) {
	data, err := os.ReadFile(cfg_path)
	checkError(err)

	err = json.Unmarshal(data, &s.conf)
	checkError(err)

	if s.conf.leftRoot == "" || s.conf.rightRoot == "" {
		panic("Both roots must be specified in the config")
	}
	s.conf.leftRoot = filepath.Clean(s.conf.leftRoot)
	s.conf.rightRoot = filepath.Clean(s.conf.rightRoot)

	if s.conf.stateDbPath == "" {
		// Build the name using sha1 for both directories
		dbPath := filepath.Clean(cfg_path)
		dbFName := filepathStem(dbPath) + "_" +
			stringHashBase32(s.conf.leftRoot+"\t"+s.conf.rightRoot) + ".sqlite"
		dbPath = filepath.Join(filepath.Dir(dbPath), dbFName)
		s.conf.stateDbPath = dbPath
	}
}

func ListFilesRsync(root string) map[string]os.FileInfo {

}

func (s *Sync) ListFiles(root string, files *map[string]os.FileInfo) {
	defer func() { s.listingDone <- struct{}{} }()
	*files = make(map[string]os.FileInfo)
	if strings.HasPrefix(root, "rsync://") {
		*files = ListFilesRsync(root)
		return
	}
	// Handle local filesystem
	err := filepath.Walk(root, func(path string, info os.FileInfo, err error) error {
		checkError(err)
		// ToDo: option to ignore empty dirs // if !info.IsDir() {
		(*files)[path] = info
		return nil
	})
	checkError(err)
}

func (s *Sync) updateDirLists() {
	go s.ListFiles(s.conf.leftRoot, &s.current.leftFiles)
	go s.ListFiles(s.conf.rightRoot, &s.current.rightFiles)
	// Wait for the file listing to complete
	<-s.listingDone
	<-s.listingDone
}

func main() {
	sync := Sync{}

	configDir, err := os.UserConfigDir()
	checkError(err)

	sync.LoadConfig(filepath.Join(configDir, "bidirectional_via_Rsync",
		"config.json"))

	sync.updateDirLists()

	// Compare the saved lists with the current lists
	leftChanges, rightChanges := sync.CompareFileLists()
	conflicts := leftChanges.Intersect(rightChanges)
	if conflicts.Len() > 0 {
		// Unresolved conflicts are just removed from both lists
		sync.ResolveConflicts(conflicts)
	}

	// Then apply the changes to both directories
	go sync.ApplyChangesToRoot(leftChanges)
	go sync.ApplyChangesToDestinationDirectory(rightChanges)

	// Save the new lists of files in both directories
	sync.SaveLists()
}
