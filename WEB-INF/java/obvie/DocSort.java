package obvie;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import org.apache.lucene.search.Sort;
import org.apache.lucene.search.SortField;

import alix.lucene.Alix;
import alix.util.EnumOption;

public enum DocSort implements EnumOption
{
  score("Pertinence", null),
  year("Année (+ ancien)", new Sort(new SortField("year", SortField.Type.INT))),
  year_inv("Année (+ récent)", new Sort(new SortField("year", SortField.Type.INT, true))),
  author("Auteur (A-Z)", new Sort(new SortField(Alix.ID, SortField.Type.STRING))),
  author_inv("Auteur (Z-A)", new Sort(new SortField(Alix.ID, SortField.Type.STRING, true))),
  //freq("Fréquence"),
  // "tf-idf", "bm25", "dfi_chi2", "dfi_std", "dfi_sat", 
  // "lmd", "lmd0.1", "lmd0.7", "dfr", "ib"
  // "tf-idf", "BM25", "DFI chi²", "DFI standard", "DFI saturé", 
  // "LMD", "LMD λ=0.1", "LMD λ=0.7", "DFR", "IB"
  ;
  public final String label;
  public final Sort sort;
  private DocSort(final String label, final Sort sort)
  {
    this.label = label;
    this.sort = sort;
  }
  
  public Sort sort()
  {
    return sort;
  }
  
  // sadly repeating myself because enum can’t inherit from an abstract class (an
  // Enum already extends a class).

  @Override
  public String label()
  {
    return label;
  }

  @Override
  public List<EnumOption> list()
  {
    return list;
  }

  public static List<EnumOption> list;
  static {
    list = Collections.unmodifiableList(Arrays.asList((EnumOption[]) values()));
  }
}
